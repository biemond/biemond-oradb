# == Class: oradb::rcu
#    rcu for soa suite, webcenter
#
#    product = soasuite|webcenter|oim|all
#
#    oradb::rcu{ 'DEV_PS6':
#                rcuFile        => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
#                version        => '11.1.1.7',
#                oracleHome     => '/oracle/product/11.2/db',
#                product        => 'all',
#                user           => 'oracle',
#                group          => 'dba',
#                downloadDir    => '/install',
#                action         => 'create',
#                dbServer       => 'dbagent1.alfa.local:1521',
#                dbService      => 'test.oracle.com',
#                sysPassword    => 'Welcome01',
#                schemaPrefix   => 'DEV',
#                reposPassword  => 'Welcome02',
#    }
#
#
define oradb::rcu(
  $rcuFile                 = undef,
  $product                 = 'soasuite',
  $version                 = '11.1.1.7',
  $oracleHome              = undef,
  $user                    = 'oracle',
  $group                   = 'dba',
  $downloadDir             = '/install',
  $action                  = 'create',  # delete or create
  $dbServer                = undef,
  $dbService               = undef,
  $sysPassword             = undef,
  $schemaPrefix            = undef,
  $reposPassword           = undef,
  $tempTablespace          = undef,
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
  $logoutput               = false,
){
  case $::kernel {
    'Linux': {
      $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
    }
    default: {
      fail('Unrecognized or not supported operating system')
    }
  }

  if $puppetDownloadMntPoint == undef {
    $mountPoint = 'puppet:///modules/oradb/'
  } else {
    $mountPoint = $puppetDownloadMntPoint
  }

  # create the rcu folder
  if ! defined(File["${downloadDir}/rcu_${version}"]) {
    # check rcu install folder
    file { "${downloadDir}/rcu_${version}":
      ensure  => directory,
      path    => "${downloadDir}/rcu_${version}",
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  # unzip rcu software
  if $remoteFile == true {
    if ! defined(File["${downloadDir}/${rcuFile}"]) {
      file { "${downloadDir}/${rcuFile}":
        ensure => present,
        mode   => '0775',
        owner  => $user,
        group  => $group,
        source => "${mountPoint}/${rcuFile}",
        before => Exec["extract ${rcuFile}"],
      }
    }
    $source = $downloadDir
  } else {
    $source = $mountPoint
  }

  if ! defined(Exec["extract ${rcuFile}"]) {
    exec { "extract ${rcuFile}":
      command   => "unzip ${source}/${rcuFile} -d ${downloadDir}/rcu_${version}",
      creates   => "${downloadDir}/rcu_${version}/rcuHome",
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => false,
    }
  }

  if ! defined(File["${downloadDir}/rcu_${version}/rcuHome/rcu/log"]) {
    # check rcu log folder
    file { "${downloadDir}/rcu_${version}/rcuHome/rcu/log":
      ensure  => directory,
      path    => "${downloadDir}/rcu_${version}/rcuHome/rcu/log",
      recurse => false,
      replace => false,
      require => Exec["extract ${rcuFile}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  if $product == 'soasuite' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM'
    $componentsPasswords  = [$reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword]
  } elsif $product == 'webcenter' {
    $components           = '-component MDS -component OPSS -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [$reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword]
  } elsif $product == 'oim' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component IAU -component OIF -component OIM -component OAM -component OAAM'
    $componentsPasswords  = [$reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword,$reposPassword, $reposPassword, $reposPassword,$reposPassword, $reposPassword]
  } elsif $product == 'all' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [ $reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword, $reposPassword]
  } else {
    fail('Unrecognized FMW product')
  }

  file { "${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure  => present,
    require => Exec["extract ${rcuFile}"],
    content => template('oradb/rcu_passwords.txt.erb'),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  if ( $oracleHome != undef ) {
    $preCommand    = "export SQLPLUS_HOME=${oracleHome};${downloadDir}/rcu_${version}/rcuHome/bin/rcu -silent"
  } else {
    $preCommand    = "${downloadDir}/rcu_${version}/rcuHome/bin/rcu -silent"
  }
  $postCommand     = "-databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} "
  $passwordCommand = " -f < ${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"

  #optional set the Temp tablespace
  if $tempTablespace == undef {
    $createCommand  = "${preCommand} -createRepository ${postCommand} ${passwordCommand}"
  } else {
    $createCommand  = "${preCommand} -createRepository ${postCommand} -tempTablespace ${tempTablespace} ${passwordCommand}"
  }
  $deleteCommand  = "${preCommand} -dropRepository ${postCommand} ${passwordCommand}"

  if $action == 'create' {
    $statement = $createCommand
  }
  elsif $action == 'delete' {
    $statement = $deleteCommand
  }

  db_rcu{ $schemaPrefix:
    ensure       => $action,
    statement    => $statement,
    os_user      => $user,
    oracle_home  => $oracleHome,
    sys_password => $sysPassword,
    db_server    => $dbServer,
    db_service   => $dbService,
    require      => [Exec["extract ${rcuFile}"],
                    File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"],],
  }

}
