# == Class: oradb::rcu
#    rcu for soa suite, webcenter
#
define oradb::rcu(
  String $rcu_file                  = undef,
  Enum["soasuite", "webcenter", "oam", "oim", "all"] $product = 'soasuite',
  String $version                   = '11.1.1.7',
  $oracle_home                      = undef,
  String $user                      = lookup('oradb::user'),
  String $group                     = lookup('oradb::group'),
  String $download_dir              = lookup('oradb::download_dir'),
  Enum["delete", "create"] $action  = 'create',
  String $db_server                 = undef,
  String $db_service                = undef,
  String $sys_user                  = 'sys',
  String $sys_password              = undef,
  String $schema_prefix             = undef,
  String $repos_password            = undef,
  $temp_tablespace                  = undef,
  String $puppet_download_mnt_point = lookup('oradb::module_mountpoint'),
  Boolean $remote_file              = true,
  Boolean $logoutput                = false,
){
  $execPath = lookup('oradb::exec_path')

  # create the rcu folder
  if ! defined(File["${download_dir}/rcu_${version}"]) {
    # check rcu install folder
    file { "${download_dir}/rcu_${version}":
      ensure  => directory,
      path    => "${download_dir}/rcu_${version}",
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  # unzip rcu software
  if $remote_file == true {
    if ! defined(File["${download_dir}/${rcu_file}"]) {
      file { "${download_dir}/${rcu_file}":
        ensure => present,
        mode   => '0775',
        owner  => $user,
        group  => $group,
        source => "${puppet_download_mnt_point}/${rcu_file}",
        before => Exec["extract ${rcu_file}"],
      }
    }
    $source = $download_dir
  } else {
    $source = $puppet_download_mnt_point
  }

  if ! defined(Exec["extract ${rcu_file}"]) {
    exec { "extract ${rcu_file}":
      command   => "unzip ${source}/${rcu_file} -d ${download_dir}/rcu_${version}",
      creates   => "${download_dir}/rcu_${version}/rcuHome",
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => false,
    }
  }

  # rcuHome is read only for non-root user so put log dir above it
  if ! defined(File["${download_dir}/rcu_${version}/log"]) {
    # check rcu log folder
    file { "${download_dir}/rcu_${version}/log":
      ensure  => directory,
      path    => "${download_dir}/rcu_${version}/log",
      recurse => false,
      replace => false,
      require => Exec["extract ${rcu_file}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  if $product == 'soasuite' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password]
  } elsif $product == 'webcenter' {
    $components           = '-component MDS -component OPSS -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oam' {
    $components           = '-component MDS -component OPSS -component IAU -component OAM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oim' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component IAU -component BIPLATFORM -component OIF -component OIM -component OAM -component OAAM -component OMSM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password,$repos_password, $repos_password, $repos_password,$repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'all' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [ $repos_password, $repos_password, $repos_password,$repos_password,$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } else {
    fail('Unrecognized FMW product')
  }

  file { "${download_dir}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure  => present,
    require => Exec["extract ${rcu_file}"],
    content => template('oradb/rcu_passwords.txt.erb'),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  if ( $oracle_home != undef ) {
    $preCommand    = "export SQLPLUS_HOME=${oracle_home};export RCU_LOG_LOCATION=${download_dir}/rcu_${version}/log;${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  } else {
    $preCommand    = "export RCU_LOG_LOCATION=${download_dir}/rcu_${version}/log;${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  }
  $postCommand     = "-databaseType ORACLE -connectString ${db_server}:${db_service} -dbUser ${sys_user} -dbRole SYSDBA -schemaPrefix ${schema_prefix} ${components} "
  $passwordCommand = " -f < ${download_dir}/rcu_${version}/rcu_passwords_${title}.txt"

  #optional set the Temp tablespace
  if $temp_tablespace == undef {
    $createCommand  = "${preCommand} -createRepository ${postCommand} ${passwordCommand}"
  } else {
    $createCommand  = "${preCommand} -createRepository ${postCommand} -tempTablespace ${temp_tablespace} ${passwordCommand}"
  }
  $deleteCommand  = "${preCommand} -dropRepository ${postCommand} ${passwordCommand}"

  if $action == 'create' {
    $statement = $createCommand
  }
  elsif $action == 'delete' {
    $statement = $deleteCommand
  }

  db_rcu{ $schema_prefix:
    ensure       => $action,
    statement    => $statement,
    os_user      => $user,
    oracle_home  => $oracle_home,
    sys_user     => $sys_user,
    sys_password => $sys_password,
    db_server    => $db_server,
    db_service   => $db_service,
    require      => [Exec["extract ${rcu_file}"],
                    File["${download_dir}/rcu_${version}/rcu_passwords_${title}.txt"],],
  }

}
