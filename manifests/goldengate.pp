#
#
#
define oradb::goldengate(
  $version                 = '12.1.2',
  $file                    = undef,
  $tarFile                 = undef,     # only for < 12.1.2
  $databaseType            = 'Oracle',  # only for > 12.1.2
  $databaseVersion         = 'ORA11g',  # 'ORA11g'|'ORA12c'  only for > 12.1.2
  $databaseHome            = undef,     # only for > 12.1.2
  $oracleBase              = undef,     # only for > 12.1.2
  $goldengateHome          = undef,
  $managerPort             = undef,
  $user                    = 'ggate',
  $group                   = 'dba',
  $group_install           = 'oinstall',
  $downloadDir             = '/install',
  $puppetDownloadMntPoint  = undef,
)
{
  if ( $version == '12.1.2' ) {
    # check if the oracle software already exists
    $found = oracle_exists( $goldengateHome )

    if $found == undef {
      $continue = true
    } else {
      if ( $found ) {
        $continue = false
      } else {
        notify {"oradb::goldengate ${goldengateHome} does not exists":}
        $continue = true
      }
    }
  } else {
    $continue = false
  }

  # only for 12.1.2
  if ( $continue == true ) {

    $oraInventory    = "${oracleBase}/oraInventory"
    $ggateInstallDir = 'fbo_ggs_Linux_x64_shiphome'

    file { "${downloadDir}/${file}":
      source => "${puppetDownloadMntPoint}/${file}",
      owner  => $user,
      group  => $group,
    }

    exec { 'extract gg':
      command   => "unzip -o ${downloadDir}/${file} -d ${downloadDir}",
      require   => File["${downloadDir}/${file}"],
      creates   => "${downloadDir}/${ggateInstallDir}",
      timeout   => 0,
      path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
      user      => $user,
      group     => $group,
      logoutput => true,
    }

    file { "${downloadDir}/oggcore.rsp":
      content => template("oradb/oggcore_${version}.rsp.erb"),
      owner   => $user,
      group   => $group,
    }

    oradb::utils::dborainst{"ggate orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    exec { 'install oracle goldengate':
      command   => "/bin/sh -c 'unset DISPLAY;${downloadDir}/${ggateInstallDir}/Disk1/runInstaller -silent -waitforcompletion -responseFile ${downloadDir}/oggcore.rsp'",
      require   => [ File["${downloadDir}/oggcore.rsp"],Oradb::Utils::Dborainst["ggate orainst ${version}"],Exec['extract gg'],],
      creates   => $goldengateHome,
      timeout   => 0,
      path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
      logoutput => true,
      user      => $user,
      group     => $group_install,
      returns   => [3,0],
    }

} else {
    #version is different, use the old way
    file { "${downloadDir}/${file}":
      source => "${puppetDownloadMntPoint}/${file}",
      owner  => $user,
      group  => $group,
    }

    exec { "extract gg ${title}":
      command   => "unzip -o ${downloadDir}/${file} -d ${downloadDir}",
      require   => File["${downloadDir}/${file}"],
      creates   => "${downloadDir}/${tarFile}",
      timeout   => 0,
      path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
      user      => $user,
      group     => $group,
      logoutput => true,
    }

    file { $goldengateHome :
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }

    exec { "extract tar ${title}":
      command   => "tar -xf ${downloadDir}/${tarFile} -C ${goldengateHome}",
      require   => [File[$goldengateHome],Exec["extract gg ${title}"]],
      creates   => "${goldengateHome}/ggsci",
      timeout   => 0,
      path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
      user      => $user,
      group     => $group,
      logoutput => true,
    }
  }
}