# == Class: oradb::client
#
#
define oradb::client(    $version                 = undef,
                         $file                    = undef,
                         $oracleBase              = undef,
                         $oracleHome              = undef,
                         $createUser              = true,
                         $user                    = 'oracle',
                         $userBaseDir             = '/home',
                         $group                   = 'dba',
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

    $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
    $oraInventory = "${oracleBase}/oraInventory"

    if $puppetDownloadMntPoint == undef {
      $mountPoint     = "puppet:///modules/oradb/"
    } else {
      $mountPoint     = $puppetDownloadMntPoint
    }

    oradb::utils::structure{"oracle structure ${version}":
      oracle_base_home_dir => $oracleBase,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      download_dir         => $downloadDir,
      log_output           => true,
      user_base_dir        => $userBaseDir,
      create_user          => $createUser,
    }


    # db file installer zip
    if $remoteFile == true {
      file { "${downloadDir}/${file}":
        source      => "${mountPoint}/${file}",
        require     => Oradb::Utils::Structure["oracle structure ${version}"],
        ensure      => present,
        mode        => 0775,
        owner       => $user,
        group       => $group,
      }
      exec { "extract ${downloadDir}/${file}":
        command     => "unzip -o ${downloadDir}/${file} -d ${downloadDir}/client_${version}",
        require     => File["${downloadDir}/${file}"],
        creates     => "${downloadDir}/client_${version}/client/install/addLangs.sh",
        timeout     => 0,
        path        => $execPath,
        user        => $user,
        group       => $group,
       logoutput    => $logoutput,
      }
    } else {
      exec { "extract ${downloadDir}/${file}":
        command     => "unzip -o ${mountPoint}/${file} -d ${downloadDir}/client_${version}",
        creates     => "${downloadDir}/client_${version}/client/install/addLangs.sh",
        require     => Oradb::Utils::Structure["oracle structure ${version}"],
        timeout     => 0,
        path        => $execPath,
        user        => $user,
        group       => $group,
       logoutput    => $logoutput,
      }
    }

    oradb::utils::orainst{"oracle orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group,
    }

    if ! defined(File["${downloadDir}/db_client_${version}.rsp"]) {
      file { "${downloadDir}/db_client_${version}.rsp":
        ensure      => present,
        content     => template("oradb/db_client_${version}.rsp.erb"),
        require     => Oradb::Utils::Orainst["oracle orainst ${version}"],
        mode        => 0775,
        owner       => $user,
        group       => $group,
      }
    }

    # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
    exec { "install oracle client ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${downloadDir}/client_${version}/client/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${downloadDir}/db_client_${version}.rsp'",
      require     => [Oradb::Utils::Orainst["oracle orainst ${version}"],
                      File["${downloadDir}/db_client_${version}.rsp"],
                      Exec["extract ${downloadDir}/${file}"]],
      creates     => $oracleHome,
      timeout     => 0,
      returns     => [6,0],
      path        => $execPath,
      user        => $user,
      group       => $group,
      logoutput   => $logoutput,
    }

    exec { "run root.sh script ${title}":
      command         => "${oracleHome}/root.sh",
      user            => 'root',
      group           => 'root',
      require         => Exec["install oracle client ${title}"],
      path            => $execPath,
      logoutput       => $logoutput,
    }

    file { "${downloadDir}/netca_client_${version}.rsp":
      ensure       => present,
      content      => template("oradb/netca_client_${version}.rsp.erb"),
      require      => Exec["run root.sh script ${title}"],
      mode         => 0775,
      owner        => $user,
      group        => $group,
    }

    exec { "install oracle net ${title}":
      command        => "${oracleHome}/bin/netca /silent /responsefile ${downloadDir}/netca_client_${version}.rsp",
      require        => [File["${downloadDir}/netca_client_${version}.rsp"],
                         Exec["run root.sh script ${title}"],
                        ],
      creates        => "${oracleHome}/network/admin/sqlnet.ora",
      path           => $execPath,
      user           => $user,
      group          => $group,
      logoutput      => $logoutput,
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure        => present,
        content       => template("oradb/bash_profile.erb"),
        mode          => 0775,
        owner         => $user,
        group         => $group,
      }
    }

  }
}
