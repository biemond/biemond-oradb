# == Class: oradb::database
#
#
# action        =  createDatabase|deleteDatabase
# databaseType  = MULTIPURPOSE|DATA_WAREHOUSING|OLTP
#
#
#  oradb::database{ 'testDb':
#                   oracleBase              => '/oracle',
#                   oracleHome              => '/oracle/product/11.2/db',
#                   user                    => 'oracle',
#                   group                   => 'dba',
#                   downloadDir             => '/install',
#                   action                  => 'create',
#                   dbName                  => 'test',
#                   dbDomain                => 'oracle.com',
#                   sysPassword             => 'Welcome01',
#                   systemPassword          => 'Welcome01',
#                   dataFileDestination     => "/oracle/oradata",
#                   recoveryAreaDestination => "/oracle/flash_recovery_area",
#                   characterSet            => "AL32UTF8",
#                   nationalCharacterSet    => "UTF8",
#                   initParams              => "open_cursors=1000,processes=600,job_queue_processes=4,compatible=11.2.0.0.0",
#                   sampleSchema            => 'TRUE',
#                   memoryPercentage        => "40",
#                   memoryTotal             => "800",
#                   databaseType            => "MULTIPURPOSE",
#                   require                 => Oradb::Listener['start listener'],
#  }
#
#
#
define oradb::database( $oracleBase               = undef,
                        $oracleHome               = undef,
                        $version                  = "11.2",
                        $user                     = 'oracle',
                        $group                    = 'dba',
                        $downloadDir              = '/install',
                        $action                   = 'create',
                        $dbName                   = 'orcl',
                        $dbDomain                 = 'oracle.com',
                        $sysPassword              = 'Welcome01',
                        $systemPassword           = 'Welcome01',
                        $dataFileDestination      = undef,
                        $recoveryAreaDestination  = undef,
                        $characterSet             = "AL32UTF8",
                        $nationalCharacterSet     = "UTF8",
                        $initParams               = undef,
                        $sampleSchema             = TRUE,
                        $memoryPercentage         = "40",
                        $memoryTotal              = "800",
                        $databaseType             = "MULTIPURPOSE",
)

{
  if $version == "11.2" or $version == "12.1" {
  } else {
    fail("Unrecognized version")
  }
  $continue = true

  if ( $continue ) {
    case $::kernel {
      Linux,SunOS: {
        $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path        = $downloadDir
        Exec { path  => $execPath,
          user       => $user,
          group      => $group,
          logoutput  => true,
        }
        File {
          ensure     => present,
          mode       => 0775,
          owner      => $user,
          group      => $group,
        }
      }
      default: {
        fail("Unrecognized operating system")
      }
    }

    if $action == 'create' {
      $operationType = 'createDatabase'
    } elsif $action == 'delete' {
      $operationType = 'deleteDatabase'
    } else {
      fail("Unrecognized database action")
    }

    $globalDbName    = "${dbName}.${dbDomain}"
    if ! defined(File["${path}/database_${title}.rsp"]) {
      file { "${path}/database_${title}.rsp":
        ensure       => present,
        content      => template("oradb/dbca_${version}.rsp.erb"),
      }
    }

    if $action == 'create' {
      exec { "install oracle database ${title}":
        command      => "dbca -silent -responseFile ${path}/database_${title}.rsp",
        require      => File["${path}/database_${title}.rsp"],
        creates      => "${oracleBase}/admin/${dbName}",
        timeout      => 0,
      }
    } elsif $action == 'delete' {
      exec { "delete oracle database ${title}":
        command      => "dbca -silent -responseFile ${path}/database_${title}.rsp",
        require      => File["${path}/database_${title}.rsp"],
        onlyif       => "ls ${oracleBase}/admin/${dbName}",
        timeout      => 0,
      }
    }
  }
}