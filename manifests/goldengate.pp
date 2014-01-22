define oradb::goldengate( $version                 = '12.1.2',
                          $file                    = undef,
                          $databaseType            = 'Oracle',
                          $databaseVersion         = 'ORA11g',  # 'ORA11g'|'ORA12c'
                          $databaseHome            = undef,
                          $oracleBase              = undef,
                          $goldengateHome          = undef,
                          $managerPort             = undef,
                          $user                    = 'ggate',
                          $group                   = 'dba',
                          $downloadDir             = '/install',
                          $puppetDownloadMntPoint  = undef,
)
{

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

  if ( $continue ) {

      $oraInventory = "${oracleBase}/oraInventory"

      case $::kernel {
        Linux: {
          $oraInstPath  = "/etc"
        }
        SunOS: {
          $oraInstPath  = "/var/opt"
        }
        default: {
          fail("Unrecognized operating system")
        }
      }

      if ( $version == '12.1.2' ) {
        $ggateInstallDir = 'fbo_ggs_Linux_x64_shiphome'
      }
      
      file { "${downloadDir}/${file}":
        source      => "${puppetDownloadMntPoint}/${file}",
        owner       => $user,
        group       => $group,
      }

      exec { "extract gg":
        command     => "unzip -o ${downloadDir}/${file} -d ${downloadDir}",
        require     => File["${downloadDir}/${file}"],
        creates     => "${downloadDir}/${ggateInstallDir}",
        timeout     => 0,
        path        => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
        user        => $user,
        group       => $group,
        logoutput   => true,
     }

      file { "${downloadDir}/oggcore.rsp":
        content     => template("oradb/oggcore_${version}.rsp.erb"),
        owner       => $user,
        group       => $group,
      }

      if ! defined(File["${oraInstPath}/oraInst.loc"]) {
        file { "${oraInstPath}/oraInst.loc":
          ensure        => present,
          content       => template("oradb/oraInst.loc.erb"),
        }
      }
      
      exec { "install oracle goldengate":
          command     => "/bin/sh -c 'unset DISPLAY;${downloadDir}/${ggateInstallDir}/Disk1/runInstaller -silent -waitforcompletion -invPtrLoc ${oraInstPath}/oraInst.loc -responseFile ${downloadDir}/oggcore.rsp'",
          require     => [ File["${downloadDir}/oggcore.rsp"],
                           File["${oraInstPath}/oraInst.loc"],
                           Exec["extract gg"]
                         ],
          creates     => $goldengateHome,
          timeout     => 0,
          path        => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
          logoutput   => true,
          user        => $user,
          group       => $group,
          returns     => [3,0],
      }

  }
}