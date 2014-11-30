# == Class: oradb::database
#
#
# action        =  createDatabase|deleteDatabase
# databaseType  = MULTIPURPOSE|DATA_WAREHOUSING|OLTP
#
define oradb::database(
  $oracleBase               = undef,
  $oracleHome               = undef,
  $version                  = '11.2',
  $user                     = 'oracle',
  $group                    = 'dba',
  $downloadDir              = '/install',
  $action                   = 'create',
  $template                 = undef,
  $dbName                   = 'orcl',
  $dbDomain                 = undef,
  $dbPort                   = '1521',
  $sysPassword              = 'Welcome01',
  $systemPassword           = 'Welcome01',
  $dataFileDestination      = undef,
  $recoveryAreaDestination  = undef,
  $characterSet             = 'AL32UTF8',
  $nationalCharacterSet     = 'UTF8',
  $initParams               = undef,
  $sampleSchema             = TRUE,
  $memoryPercentage         = '40',
  $memoryTotal              = '800',
  $databaseType             = 'MULTIPURPOSE',
  $emConfiguration          = 'NONE',  # CENTRAL|LOCAL|ALL|NONE
  $storageType              = 'FS', #FS|CFS|ASM
  $asmSnmpPassword          = 'Welcome01',
  $dbSnmpPassword           = 'Welcome01',
  $asmDiskgroup             = 'DATA',
  $recoveryDiskgroup        = undef,
  $cluster_nodes            = undef,
){
  if (!( $version in ['11.2','12.1'])) {
    fail('Unrecognized version')
  }

  if $action == 'create' {
    $operationType = 'createDatabase'
  } elsif $action == 'delete' {
    $operationType = 'deleteDatabase'
  } else {
    fail('Unrecognized database action')
  }

  if (!( $databaseType in ['MULTIPURPOSE','DATA_WAREHOUSING','OLTP'])) {
    fail('Unrecognized databaseType')
  }

  if (!( $emConfiguration in ['NONE','CENTRAL','LOCAL','ALL'])) {
    fail('Unrecognized emConfiguration')
  }

  if (!( $storageType in ['FS','CFS','ASM'])) {
    fail('Unrecognized storageType')
  }

  $continue = true

  if ( $continue ) {
    case $::kernel {
      'Linux', 'SunOS': {
        $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path        = $downloadDir
      }
      default: {
        fail('Unrecognized operating system')
      }
    }

    $sanitized_title = regsubst($title, '[^a-zA-Z0-9.-]', '_', 'G')

    $filename = "${path}/database_${sanitized_title}.rsp"

    if $dbDomain {
      $globalDbName = "${dbName}.${dbDomain}"
    } else {
      $globalDbName = $dbName
    }

    if ! defined(File[$filename]) {
      file { $filename:
        ensure  => present,
        content => template("oradb/dbca_${version}.rsp.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      }
    }

    if ( $template ) {
      $templatename = "${path}/${template}_${sanitized_title}.dbt"
      file { $templatename:
        ensure  => present,
        content => template("oradb/${template}.dbt.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        before  => Exec["oracle database ${title}"],
      }
    }

    if $action == 'create' {
      if ( $template ) {
        $command = "dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globalDbName} -responseFile NO_VALUE -sysPassword ${sysPassword} -systemPassword ${systemPassword}"
      } else {
        $command = "dbca -silent -responseFile ${filename}"
      }
      exec { "oracle database ${title}":
        command     => $command,
        creates     => "${oracleBase}/admin/${dbName}",
        timeout     => 0,
        path        => $execPath,
        user        => $user,
        group       => $group,
        cwd         => $oracleBase,
        environment => ["USER=${user}",],
        logoutput   => true,
      }
    } elsif $action == 'delete' {
      exec { "oracle database ${title}":
        command     => "dbca -silent -responseFile ${filename}",
        onlyif      => "ls ${oracleBase}/admin/${dbName}",
        timeout     => 0,
        path        => $execPath,
        user        => $user,
        group       => $group,
        cwd         => $oracleBase,
        environment => ["USER=${user}",],
        logoutput   => true,
      }
    }
  }
}