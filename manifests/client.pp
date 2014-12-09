# == Class: oradb::client
#
#
define oradb::client(
  $version                 = undef,
  $file                    = undef,
  $oracleBase              = undef,
  $oracleHome              = undef,
  $dbPort                  = '1521',
  $createUser              = true,
  $user                    = 'oracle',
  $userBaseDir             = '/home',
  $group                   = 'dba',
  $group_install           = 'oinstall',
  $downloadDir             = '/install',
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
  $logoutput               = true,
)
{
  # check if the oracle software already exists
  $found = oracle_exists( $oracleHome )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installdb ${oracleHome} does not exists":}
      $continue = true
    }
  }

  if ( $continue ) {

    $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
    $oraInventory = "${oracleBase}/oraInventory"

    if $puppetDownloadMntPoint == undef {
      $mountPoint     = 'puppet:///modules/oradb/'
    } else {
      $mountPoint     = $puppetDownloadMntPoint
    }

    oradb::utils::dbstructure{"oracle structure ${version}":
      oracle_base_home_dir => $oracleBase,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      os_group_install     => $group_install,
      os_group_oper        => undef,
      download_dir         => $downloadDir,
      log_output           => true,
      user_base_dir        => $userBaseDir,
      create_user          => $createUser,
    }


    # db file installer zip
    if $remoteFile == true {
      file { "${downloadDir}/${file}":
        ensure  => present,
        source  => "${mountPoint}/${file}",
        require => Oradb::Utils::Dbstructure["oracle structure ${version}"],
        before  => Exec["extract ${downloadDir}/${file}"],
        mode    => '0775',
        owner   => $user,
        group   => $group,
      }
      $source = $downloadDir
    } else {
      $source = $mountPoint
    }
    exec { "extract ${downloadDir}/${file}":
      command   => "unzip -o ${source}/${file} -d ${downloadDir}/client_${version}",
      require   => Oradb::Utils::Dbstructure["oracle structure ${version}"],
      timeout   => 0,
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => false,
    }

    oradb::utils::dborainst{"oracle orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${downloadDir}/db_client_${version}.rsp"]) {
      file { "${downloadDir}/db_client_${version}.rsp":
        ensure  => present,
        content => template("oradb/db_client_${version}.rsp.erb"),
        require => Oradb::Utils::Dborainst["oracle orainst ${version}"],
        mode    => '0775',
        owner   => $user,
        group   => $group,
      }
    }

    # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
    exec { "install oracle client ${title}":
      command   => "/bin/sh -c 'unset DISPLAY;${downloadDir}/client_${version}/client/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${downloadDir}/db_client_${version}.rsp'",
      require   => [Oradb::Utils::Dborainst["oracle orainst ${version}"],
                    File["${downloadDir}/db_client_${version}.rsp"],
                    Exec["extract ${downloadDir}/${file}"]],
      creates   => $oracleHome,
      timeout   => 0,
      returns   => [6,0],
      path      => $execPath,
      user      => $user,
      group     => $group_install,
      logoutput => $logoutput,
    }

    exec { "run root.sh script ${title}":
      command   => "${oracleHome}/root.sh",
      user      => 'root',
      group     => 'root',
      require   => Exec["install oracle client ${title}"],
      path      => $execPath,
      logoutput => $logoutput,
    }

    file { "${downloadDir}/netca_client_${version}.rsp":
      ensure  => present,
      content => template("oradb/netca_client_${version}.rsp.erb"),
      require => Exec["run root.sh script ${title}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }

    exec { "install oracle net ${title}":
      command   => "${oracleHome}/bin/netca /silent /responsefile ${downloadDir}/netca_client_${version}.rsp",
      require   => [File["${downloadDir}/netca_client_${version}.rsp"],Exec["run root.sh script ${title}"],],
      creates   => "${oracleHome}/network/admin/sqlnet.ora",
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => $logoutput,
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure  => present,
        # content => template('oradb/bash_profile.erb'),
        content => regsubst(template('oradb/bash_profile.erb'), '\r\n', "\n", 'EMG'),
        mode    => '0775',
        owner   => $user,
        group   => $group,
      }
    }

    # cleanup
    exec { "remove oracle client extract folder ${title}":
      command => "rm -rf ${downloadDir}/client_${version}",
      user    => 'root',
      group   => 'root',
      path    => $execPath,
      require => Exec["install oracle net ${title}"],
    }

    if ( $remoteFile == true ){
      exec { "remove oracle client file ${file} ${title}":
        command => "rm -rf ${downloadDir}/${file}",
        user    => 'root',
        group   => 'root',
        path    => $execPath,
        require => Exec["install oracle net ${title}"],
      }
    }

  }
}
