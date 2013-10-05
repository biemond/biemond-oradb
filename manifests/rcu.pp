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
                   $puppetDownloadMntPoint  = undef,
                   $logoutput               = false,
)

{
  case $operatingsystem {
    CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: {
      $execPath           = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
      $path               = $downloadDir

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
      fail("Unrecognized operating system")
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
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component IAU -component OID -component OIF -component OIM -component OAM -component OAAM'
    $componentsPasswords  = [$reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword,$reposPassword, $reposPassword, $reposPassword,$reposPassword,$reposPassword, $reposPassword]
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
    $mountPoint           =	$puppetDownloadMntPoint
  }

  # create the rcu folder
  if ! defined(File["${path}/rcu_${version}"]) {
    # check rcu install folder
    file { "${path}/rcu_${version}":
      path                => "${path}/rcu_${version}",
      ensure              => directory,
      recurse             => false,
      replace             => false,
    }
  }

  # put check_rcu.sql
  file { "${path}/rcu_${version}/rcu_checks_${title}.sql":
    ensure                => present,
    content               => template("oradb/rcu_checks.sql.erb"),
    require               => File["${path}/rcu_${version}"],
  }

  # run check.sql
  exec { "run sqlplus to check for repos ${title}":
    command               => "sqlplus \"sys/${sysPassword}@//${dbServer}/${dbService} as sysdba\" @${path}/rcu_${version}/rcu_checks_${title}.sql",
    require               => File["${path}/rcu_${version}/rcu_checks_${title}.sql"],
    environment           => ["ORACLE_HOME=${oracleHome}",
                              "LD_LIBRARY_PATH=${oracleHome}/lib"],
  }

  # put rcu software
  if ! defined(File["${path}/${rcuFile}"]) {
    file { "${path}/${rcuFile}":
      source              => "${mountPoint}/${rcuFile}",
    }
  }

  # unzip rcu software
  if ! defined(Exec["extract ${rcuFile}"]) {
    exec { "extract ${rcuFile}":
      command             => "unzip ${path}/${rcuFile} -d ${path}/rcu_${version}",
      require             => File ["${path}/${rcuFile}"],
      creates             => "${path}/rcu_${version}/rcuHome",
    }
  }

  if ! defined(File["${path}/rcu_${version}/rcuHome/rcu/log"]) {
    # check rcu log folder
    file { "${path}/rcu_${version}/rcuHome/rcu/log":
      path                => "${path}/rcu_${version}/rcuHome/rcu/log",
      ensure              => directory,
      recurse             => false,
      replace             => false,
      require             => Exec ["extract ${rcuFile}"],
    }
  }

  file { "${path}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure                => present,
    require               => Exec ["extract ${rcuFile}"],
    content               => template("oradb/rcu_passwords.txt.erb"),
  }

  if $action == 'create' {
    exec { "install rcu repos ${title}":
      command             => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -createRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
      require             => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}/${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
      unless              => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
      environment         => ["ORACLE_HOME=${oracleHome}",
                              "SQLPLUS_HOME=${oracleHome}"],
    }
    exec { "install rcu repos ${title} 2":
      command             => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -createRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
      require             => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}/${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
      onlyif              => "/bin/grep -c ORA-00942 /tmp/check_rcu_${schemaPrefix}.txt",
      environment         => ["ORACLE_HOME=${oracleHome}",
                              "SQLPLUS_HOME=${oracleHome}"],
    }
  } elsif $action == 'delete' {
    exec { "delete rcu repos ${title}":
      command             => "${path}/rcu_${version}/rcuHome/bin/rcu -silent -dropRepository -databaseType ORACLE -connectString ${dbServer}:${dbService} -dbUser SYS -dbRole SYSDBA -schemaPrefix ${schemaPrefix} ${components} -f < ${path}/rcu_${version}/rcu_passwords_${title}.txt",
      require             => [Exec["extract ${rcuFile}"],Exec["run sqlplus to check for repos ${title}"],File["${path}/${rcuFile}"],File["${path}/rcu_${version}/rcu_passwords_${title}.txt"]],
      onlyif              => "/bin/grep -c found /tmp/check_rcu_${schemaPrefix}.txt",
    }
  }
}
