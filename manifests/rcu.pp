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
define oradb::rcu( $rcuFile                 = undef,
                   $product                 = 'soasuite',
                   $version                 = '11.1.1.7',
                   $oracleHome              = undef,
                   $user                    = 'oracle',
                   $group                   = 'dba',
                   $downloadDir             = '/install',
                   $action                  = 'create',
                   $dbServer                = undef,
                   $dbService               = undef,
                   $sysPassword             = undef,
                   $schemaPrefix            = undef,
                   $reposPassword           = undef,
                   $tempTablespace          = undef,
                   $puppetDownloadMntPoint  = undef,
                   $remoteFile              = true,
                   $logoutput               = false,
)
{
  case $::kernel {
    Linux: {

      $execPath           = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

      Exec { path         => $execPath,
        user              => $user,
        group             => $group,
        logoutput         => $logoutput,
      }

      File {
        ensure            => present,
        mode              => 0775,
        owner             => $user,
        group             => $group,
      }
    }
    default: {
      fail("Unrecognized or not supported operating system")
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
    fail("Unrecognized FMW product")
  }

  if $puppetDownloadMntPoint == undef {
    $mountPoint           = "puppet:///modules/oradb/"
  } else {
    $mountPoint           = $puppetDownloadMntPoint
  }

  # create the rcu folder
  if ! defined(File["${downloadDir}/rcu_${version}"]) {
    # check rcu install folder
    file { "${downloadDir}/rcu_${version}":
      path                => "${downloadDir}/rcu_${version}",
      ensure              => directory,
      recurse             => false,
      replace             => false,
    }
  }

  # only when we have an Oracle home
  if $oracleHome != undef {
    # put check_rcu.sql
    file { "${downloadDir}/rcu_${version}/rcu_checks_${title}.sql":
      ensure                => present,
      content               => template("oradb/rcu_checks.sql.erb"),
      require               => File["${downloadDir}/rcu_${version}"],
    }

    # run check.sql
    exec { "run sqlplus to check for repos ${title}":
      command               => "sqlplus \"sys/${sysPassword}@//${dbServer}/${dbService} as sysdba\" @${downloadDir}/rcu_${version}/rcu_checks_${title}.sql",
      require               => File["${downloadDir}/rcu_${version}/rcu_checks_${title}.sql"],
      environment           => ["ORACLE_HOME=${oracleHome}",
                                "LD_LIBRARY_PATH=${oracleHome}/lib"],
    }
  }

  # put rcu software
  if $remoteFile == true {
    if ! defined(File["${downloadDir}/${rcuFile}"]) {
      file { "${downloadDir}/${rcuFile}":
        source => "${mountPoint}/${rcuFile}",
      }
    }
  }


  # unzip rcu software
  if $remoteFile == true {
    if ! defined(Exec["extract ${rcuFile}"]) {
      exec { "extract ${rcuFile}":
        command             => "unzip ${downloadDir}/${rcuFile} -d ${downloadDir}/rcu_${version}",
        require             => File ["${downloadDir}/${rcuFile}"],
        creates             => "${downloadDir}/rcu_${version}/rcuHome",
        logoutput           => false,
      }
    }
  } else {
      exec { "extract ${rcuFile}":
        command             => "unzip ${mountPoint}/${rcuFile} -d ${downloadDir}/rcu_${version}",
        creates             => "${downloadDir}/rcu_${version}/rcuHome",
        logoutput           => false,
      }
  }
  if ! defined(File["${downloadDir}/rcu_${version}/rcuHome/rcu/log"]) {
    # check rcu log folder
    file { "${downloadDir}/rcu_${version}/rcuHome/rcu/log":
      path                => "${downloadDir}/rcu_${version}/rcuHome/rcu/log",
      ensure              => directory,
      recurse             => false,
      replace             => false,
      require             => Exec ["extract ${rcuFile}"],
    }
  }

  file { "${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure                => present,
    require               => Exec ["extract ${rcuFile}"],
    content               => template("oradb/rcu_passwords.txt.erb"),
  }

  $preCommand      = "${downloadDir}/rcu_${version}/rcuHome/bin/rcu -silent"
  $postCommand     = "-databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} "
  $passwordCommand = " -f < ${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"

  #optional set the Temp tablespace
  if $tempTablespace == undef {
    $createCommand  = "${preCommand} -createRepository ${postCommand} ${passwordCommand}"
  } else {
    $createCommand  = "${preCommand} -createRepository ${postCommand} -tempTablespace ${tempTablespace} ${passwordCommand}"
  }
  $deleteCommand  = "${preCommand} -dropRepository ${postCommand} ${passwordCommand}"

  # do a fast check if it already exists or is removed
  if $oracleHome != undef {
    if $action == 'create' {
      exec { "install rcu repos ${title}":
        command     => $createCommand,
        require     => [Exec["extract ${rcuFile}"],
                        Exec["run sqlplus to check for repos ${title}"],
                        File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"]],
        unless      => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
        environment => ["SQLPLUS_HOME=${oracleHome}",],
        timeout     => 0,
      }
      exec { "install rcu repos ${title} 2":
        command     => $createCommand,
        require     => [Exec["extract ${rcuFile}"],
                        Exec["run sqlplus to check for repos ${title}"],
                        File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"]],
        environment => ["SQLPLUS_HOME=${oracleHome}",],
        onlyif      => "/bin/grep -c ORA-00942 /tmp/check_rcu_${schemaPrefix}.txt",
        timeout     => 0,
      }
    } elsif $action == 'delete' {
      exec { "delete rcu repos ${title}":
        command     => $deleteCommand,
        require     => [Exec["extract ${rcuFile}"],
                        Exec["run sqlplus to check for repos ${title}"],
                        File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"]],
        environment => ["SQLPLUS_HOME=${oracleHome}",],
        onlyif      => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
        timeout     => 0,
      }
    }
  } else {
    # no oracle home, just create or remove it
    if $action == 'create' {
      exec { "install rcu repos ${title}":
        command     => $createCommand,
        require     => [Exec["extract ${rcuFile}"],
                        File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"]],
        timeout     => 0,
      }
    } elsif $action == 'delete' {
      exec { "delete rcu repos ${title}":
        command     => $deleteCommand,
        require     => [Exec["extract ${rcuFile}"],
                        File["${downloadDir}/rcu_${version}/rcu_passwords_${title}.txt"]],
        timeout     => 0,
      }
    }
  }

}
