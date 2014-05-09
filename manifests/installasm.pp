# == Class: oradb::installasm
#
#
define oradb::installasm(
  $version                 = undef,
  $file                    = undef,
  $gridType                = 'HA_CONFIG',
  $gridBase                = undef,
  $gridHome                = undef,
  $oraInventoryDir         = undef,   
  $user                    = 'grid',
  $userBaseDir             = '/home',
  $group                   = 'asmdba',
  $group_install           = 'oinstall',
  $group_oper              = 'asmoper',
  $group_asm               = 'asmadmin',
  $sys_asm_password        = 'Welcome01',
  $asm_monitor_password    = 'Welcome01',
  $asm_diskgroup           = 'DATA',
  $disk_discovery_string   = undef,
  $disk_redundancy         = 'NORMAL',
  $disks                   = undef,
  $downloadDir             = '/install',
  $zipExtract              = true,
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
)
{

  if (!( $version == '11.2.0.4')){
    fail("Unrecognized database grid install version, use 11.2.0.4")
  }

  if ( !($::kernel == 'Linux' or $::kernel == 'SunOS')){
    fail("Unrecognized operating system, please use it on a Linux or SunOS host")
  }

  if ( !($gridType == 'CRS_CONFIG' or $gridType == 'HA_CONFIG' or $gridType == 'UPGRADE' or $gridType == 'CRS_SWONLY')){
    fail("Unrecognized database grid type, please use CRS_CONFIG|HA_CONFIG|UPGRADE|CRS_SWONLY")
  }

  # check if the oracle software already exists
  $found = oracle_exists( $gridHome )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installasm ${gridHome} does not exists":}
      $continue = true
    }
  }

  if ( $continue ) {

    $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

    if $oraInventoryDir == undef {
      $oraInventory = "${gridBase}/oraInventory"
    } else {
      $oraInventory = "${oraInventoryDir}/oraInventory"
    }

    if $puppetDownloadMntPoint == undef {
      $mountPoint     = "puppet:///modules/oradb/"
    } else {
      $mountPoint     = $puppetDownloadMntPoint
    }

    oradb::utils::structure{"grid structure ${version}":
      oracle_base_home_dir => $gridBase,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      os_group_install     => $group_install,
      os_group_oper        => $group_oper,
      download_dir         => $downloadDir,
      log_output           => true,
      user_base_dir        => $userBaseDir,
      create_user          => false,
    }

    if ( $zipExtract ) {
      # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if $remoteFile == true {

        file { "${downloadDir}/${file}":
          ensure      => present,
          source      => "${mountPoint}/${file}",
          mode        => '0775',
          owner       => $user,
          group       => $group,
          require     => Oradb::Utils::Structure["grid structure ${version}"],
          before      => Exec["extract ${downloadDir}/${file}"],
        }
        $source = $downloadDir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${downloadDir}/${file}":
        command     => "unzip -o ${source}/${file} -d ${downloadDir}/grid_${version}",
        timeout     => 0,
        logoutput   => false,
        path        => $execPath,
        user        => $user,
        group       => $group,
        creates     => "${downloadDir}/grid_${version}",
        require     => Oradb::Utils::Structure["grid structure ${version}"],
        before      => Exec["install oracle grid ${title}"],
      }
    }

    oradb::utils::orainst{"grid orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${downloadDir}/grid_install_${version}.rsp"]) {
      file { "${downloadDir}/grid_install_${version}.rsp":
        ensure        => present,
        content       => template("oradb/grid_install_${version}.rsp.erb"),
        mode          => '0775',
        owner         => $user,
        group         => $group,
        require       => Oradb::Utils::Orainst["grid orainst ${version}"],
      }
    }

    exec { "install oracle grid ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${downloadDir}/grid_${version}/grid/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${downloadDir}/grid_install_${version}.rsp'",
      creates     => $gridHome,
      timeout     => 0,
      returns     => [6,0],
      path        => $execPath,
      user        => $user,
      group       => $group_install,
      logoutput   => true,
      require     => [Oradb::Utils::Orainst["grid orainst ${version}"],
                      File["${downloadDir}/grid_install_${version}.rsp"]],
    }

    file { $gridHome:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group_install,
      require => Exec["install oracle grid ${title}"],
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure  => present,
        content => template("oradb/grid_bash_profile.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Structure["grid structure ${version}"],
      }
    }

    exec { "run root.sh grid script ${title}":
      command   => "${gridHome}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      logoutput => true,
      require   => Exec["install oracle grid ${title}"],
    }

    file { "${downloadDir}/cfgrsp.properties":
      ensure  => present,
      content => template("oradb/grid_password.properties.erb"),
      mode    => '0600',
      owner   => $user,
      group   => $group,
      require => Exec["run root.sh grid script ${title}"],
    }

    exec { "run configToolAllCommands grid tool ${title}":
      command   => "${gridHome}/cfgtoollogs/configToolAllCommands RESPONSE_FILE=${downloadDir}/cfgrsp.properties",
      user      => $user,
      group     => $group_install,
      path      => $execPath,
      provider  => 'shell',
      cwd       => "${gridHome}/cfgtoollogs",
      logoutput => true,
      require   => [File["${downloadDir}/cfgrsp.properties"],
                    Exec["run root.sh grid script ${title}"],
                    Exec["install oracle grid ${title}"],
                   ],
    }

  }
}
