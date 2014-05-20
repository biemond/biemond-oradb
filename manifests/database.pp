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
#                   version                 => "11.2",
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
#                   emConfiguration         => "NONE",
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
                        $dbDomain                 = undef,
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
                        $emConfiguration          = "NONE",  # CENTRAL|LOCAL|ALL|NONE
                        $storageType              = "FS", #FS|CFS|ASM
                        $asmSnmpPassword          = 'Welcome01',
                        $asmDiskgroup             = 'DATA',
                        $recoveryDiskgroup        = undef,

)

{
  if (!( $version == "11.2" or $version == "12.1")) {
    fail("Unrecognized version")
  }

  if $action == 'create' {
    $operationType = 'createDatabase'
  } elsif $action == 'delete' {
    $operationType = 'deleteDatabase'
  } else {
    fail("Unrecognized database action")
  }

  if (!( $databaseType == "MULTIPURPOSE" or 
         $databaseType == "DATA_WAREHOUSING" or
         $databaseType == "OLTP")) {
    fail("Unrecognized databaseType")
  }

  if (!( $emConfiguration == "NONE" or 
         $emConfiguration == "CENTRAL" or
         $emConfiguration == "LOCAL" or 
         $emConfiguration == "ALL")) {
    fail("Unrecognized emConfiguration")
  }

  if (!( $storageType == "FS" or 
         $storageType == "CFS" or
         $storageType == "ASM" )) {
    fail("Unrecognized storageType")
  }

  $continue = true

  if ( $continue ) {
    case $::kernel {
      'Linux', 'SunOS': {
        $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path        = $downloadDir

        Exec { 
          path        => $execPath,
          user        => $user,
          group       => $group,
          environment => ["USER=${user}",],
          logoutput   => true,
        }

        File {
          ensure     => present,
          mode       => '0775',
          owner      => $user,
          group      => $group,
        }

      }
      default: {
        fail("Unrecognized operating system")
      }
    }

    $sanitized_title = regsubst($title, "[^a-zA-Z0-9.-]", "_", "G")

    $filename = "${path}/database_${sanitized_title}.rsp"

    if $dbDomain {
        $globalDbName = "${dbName}.${dbDomain}"
    } else {
        $globalDbName = $dbName
    }

    if ! defined(File[$filename]) {
      file { $filename:
        ensure       => present,
        content      => template("oradb/dbca_${version}.rsp.erb"),
      }
    }

    if $action == 'create' {
      exec { "install oracle database ${title}":
        command      => "dbca -silent -responseFile ${filename}",
        require      => File[$filename],
        creates      => "${oracleBase}/admin/${dbName}",
        timeout      => 0,
      }
    } elsif $action == 'delete' {
      exec { "delete oracle database ${title}":
        command      => "dbca -silent -responseFile ${filename}",
        require      => File[$filename],
        onlyif       => "ls ${oracleBase}/admin/${dbName}",
        timeout      => 0,
      }
    }
  }
}
