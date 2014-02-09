# == Class: oradb::installdb
#
# The databaseType value should contain only one of these choices.
# EE     : Enterprise Edition
# SE     : Standard Edition
# SEONE  : Standard Edition One
#
#    oradb::installdb{ '112030_Linux-x86-64':
#            version      => '11.2.0.3',
#            file         => 'p10404530_112030_Linux-x86-64',
#            databaseType => 'SE',
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            createUser   => 'true',
#            user         => 'oracle',
#            group        => 'dba',
#            downloadDir  => '/install',
#            zipExtract   => true,
#    }
#
#    oradb::installdb{ '112010_Linux-x86-64':
#            version      => '11.2.0.1',
#            file         => 'linux.x64_11gR2_database',
#            databaseType => 'SE',
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            createUser   => 'true',
#            user         => 'oracle',
#            userBaseDir  => '/localhome',
#            group        => 'dba',
#            downloadDir  => '/install',
#            zipExtract   => true,
#    }
#
#
#
define oradb::installdb( $version                 = undef,
                         $file                    = undef,
                         $databaseType            = 'SE',
                         $oracleBase              = undef,
                         $oracleHome              = undef,
                         $createUser              = true,
                         $user                    = 'oracle',
                         $userBaseDir             = '/home',
                         $group                   = 'dba',
                         $downloadDir             = '/install',
                         $zipExtract              = true,
                         $puppetDownloadMntPoint  = undef,
                         $remoteFile              = true,
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

    Exec { path   => $execPath,
      user        => $user,
      group       => $group,
      logoutput   => true,
    }

    File {
      ensure      => present,
      mode        => 0775,
      owner       => $user,
      group       => $group,
    }

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


    $path = $downloadDir

    if ( $zipExtract ) {
      # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
      if $version == '12.1.0.1' {
        # db file 1 installer zip
        if $remoteFile == true {
          file { "${path}/${file}_1of2.zip":
            source      => "${mountPoint}/${file}_1of2.zip",
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
          }
          exec { "extract ${path}/${file}_1of2.zip":
            command     => "unzip -o ${path}/${file}_1of2.zip -d ${path}/${file}",
            require     => File["${path}/${file}_1of2.zip"],
            creates     => "${path}/${file}/database/install/addLangs.sh",
            timeout     => 0,
          }
          # db file 2 installer zip
          file { "${path}/${file}_2of2.zip":
            source      => "${mountPoint}/${file}_2of2.zip",
            require     => File["${path}/${file}_1of2.zip"],
          }
          exec { "extract ${path}/${file}_2of2.zip":
            command     => "unzip -o ${path}/${file}_2of2.zip -d ${path}/${file}",
            require     => [ File["${path}/${file}_2of2.zip"],
                             Exec["extract ${path}/${file}_1of2.zip"],
                           ],
            creates     => "${path}/${file}/database/stage/Components/oracle.rdbms/12.1.0.1.0/1/DataFiles/filegroup19.6.1.jar",
            timeout     => 0,
          }
        } else {
          exec { "extract ${path}/${file}_1of2.zip":
            command     => "unzip -o ${mountPoint}/${file}_1of2.zip -d ${path}/${file}",
            creates     => "${path}/${file}/database/install/addLangs.sh",
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_2of2.zip":
            command     => "unzip -o ${mountPoint}/${file}_2of2.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_1of2.zip"],
            creates     => "${path}/${file}/database/stage/Components/oracle.rdbms/12.1.0.1.0/1/DataFiles/filegroup19.6.1.jar",
            timeout     => 0,
          }
        }
      }

      if $version == '11.2.0.1' {
        # db file 1 installer zip
        if $remoteFile == true {

          file { "${path}/${file}_1of2.zip":
            source      => "${mountPoint}/${file}_1of2.zip",
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
          }
          exec { "extract ${path}/${file}_1of2.zip":
            command     => "unzip -o ${path}/${file}_1of2.zip -d ${path}/${file}",
            require     => File["${path}/${file}_1of2.zip"],
            timeout     => 0,
          }
          # db file 2 installer zip
          file { "${path}/${file}_2of2.zip":
            source      => "${mountPoint}/${file}_2of2.zip",
            require     => File["${path}/${file}_1of2.zip"],
          }
          exec { "extract ${path}/${file}_2of2.zip":
            command     => "unzip -o ${path}/${file}_2of2.zip -d ${path}/${file}",
            require     => File["${path}/${file}_2of2.zip"],
            timeout     => 0,
          }
        } else {
          exec { "extract ${path}/${file}_1of2.zip":
            command     => "unzip -o ${mountPoint}/${file}_1of2.zip -d ${path}/${file}",
            timeout     => 0,
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
          }
          exec { "extract ${path}/${file}_2of2.zip":
            command     => "unzip -o ${mountPoint}/${file}_2of2.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_1of2.zip"],
            timeout     => 0,
          }

        }
      }

      if ( $version == '11.2.0.3' or $version == '11.2.0.4' ) {
        # db file 1 installer zip
        if $remoteFile == true {

          file { "${path}/${file}_1of7.zip":
            source      => "${mountPoint}/${file}_1of7.zip",
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
          }
          exec { "extract ${path}/${file}_1of7.zip":
            command     => "unzip -o ${path}/${file}_1of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_1of7.zip"],
            timeout     => 0,
          }
          # db file 2 installer zip
          file { "${path}/${file}_2of7.zip":
            source      => "${mountPoint}/${file}_2of7.zip",
            require     => File["${path}/${file}_1of7.zip"],
          }
          exec { "extract ${path}/${file}_2of7.zip":
            command     => "unzip -o ${path}/${file}_2of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_2of7.zip"],
            timeout     => 0,
          }
          # db file 3 installer zip
          file { "${path}/${file}_3of7.zip":
            source      => "${mountPoint}/${file}_3of7.zip",
            require     => File["${path}/${file}_2of7.zip"],
          }
          exec { "extract ${path}/${file}_3of7.zip":
            command     => "unzip -o ${path}/${file}_3of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_3of7.zip"],
            timeout     => 0,
          }
          # db file 4 installer zip
          file { "${path}/${file}_4of7.zip":
            source      => "${mountPoint}/${file}_4of7.zip",
            require     => File["${path}/${file}_3of7.zip"],
          }
          exec { "extract ${path}/${file}_4of7.zip":
            command     => "unzip -o ${path}/${file}_4of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_4of7.zip"],
            timeout     => 0,
          }
          # db file 5 installer zip
          file { "${path}/${file}_5of7.zip":
            source      => "${mountPoint}/${file}_5of7.zip",
            require     => File["${path}/${file}_4of7.zip"],
          }
          exec { "extract ${path}/${file}_5of7.zip":
            command     => "unzip -o ${path}/${file}_5of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_5of7.zip"],
            timeout     => 0,
          }
          # db file 6 installer zip
          file { "${path}/${file}_6of7.zip":
            source      => "${mountPoint}/${file}_6of7.zip",
            require     => File["${path}/${file}_5of7.zip"],
          }
          exec { "extract ${path}/${file}_6of7.zip":
            command     => "unzip -o ${path}/${file}_6of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_6of7.zip"],
            timeout     => 0,
          }
          # db file 7 installer zip
          file { "${path}/${file}_7of7.zip":
            source      => "${mountPoint}/${file}_7of7.zip",
            require     => File["${path}/${file}_6of7.zip"],
          }
          exec { "extract ${path}/${file}_7of7.zip":
            command     => "unzip -o ${path}/${file}_7of7.zip -d ${path}/${file}",
            require     => File["${path}/${file}_7of7.zip"],
            timeout     => 0,
          }
        } else {
          exec { "extract ${path}/${file}_1of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_1of7.zip -d ${path}/${file}",
            timeout     => 0,
            require     => Oradb::Utils::Structure["oracle structure ${version}"],
          }
          exec { "extract ${path}/${file}_2of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_2of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_1of7.zip"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_3of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_3of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_2of7.zip"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_4of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_4of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_3of7.zip"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_5of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_5of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_4of7.zip"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_6of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_6of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_5of7.zip"],
            timeout     => 0,
          }
          exec { "extract ${path}/${file}_7of7.zip":
            command     => "unzip -o ${mountPoint}/${file}_7of7.zip -d ${path}/${file}",
            require     => Exec["extract ${path}/${file}_6of7.zip"],
            timeout     => 0,
          }

        }
      }
    }

    oradb::utils::orainst{"database orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group,
    }

    if ! defined(File["${path}/db_install_${version}.rsp"]) {
      file { "${path}/db_install_${version}.rsp":
        ensure        => present,
        content       => template("oradb/db_install_${version}.rsp.erb"),
        require       => Oradb::Utils::Orainst["database orainst ${version}"],
      }
    }

    if $version == '12.1.0.1' {
      if ( $zipExtract ) {
        # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"],
                          Exec["extract ${path}/${file}_1of2.zip"],
                          Exec["extract ${path}/${file}_2of2.zip"]],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      } else {
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"]],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      }
    }

    if ( $version == '11.2.0.3' or $version == '11.2.0.4' ) {
      if ( $zipExtract ) {
        # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"],
                          Exec["extract ${path}/${file}_1of7.zip"],
                          Exec["extract ${path}/${file}_2of7.zip"],
                          Exec["extract ${path}/${file}_3of7.zip"],
                          Exec["extract ${path}/${file}_4of7.zip"],
                          Exec["extract ${path}/${file}_5of7.zip"],
                          Exec["extract ${path}/${file}_6of7.zip"],
                          Exec["extract ${path}/${file}_7of7.zip"]],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      } else {
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"]],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      }
    }

    if $version == '11.2.0.1' {
      if ( $zipExtract ) {
        # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -waitforcompletion -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"],
                          Exec["extract ${path}/${file}_1of2.zip"],
                          Exec["extract ${path}/${file}_2of2.zip"] ],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      } else {
        exec { "install oracle database ${title}":
          command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -waitforcompletion -responseFile ${path}/db_install_${version}.rsp'",
          require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                          File["${path}/db_install_${version}.rsp"]],
          creates     => $oracleHome,
          timeout     => 0,
          returns     => [6,0],
        }
      }
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure        => present,
        content       => template("oradb/bash_profile.erb"),
      }
    }

    exec { "run root.sh script ${title}":
      command         => "${oracleHome}/root.sh",
      user            => 'root',
      group           => 'root',
      require         => Exec["install oracle database ${title}"],
    }
  }
}
