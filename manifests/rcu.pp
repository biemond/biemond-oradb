#
# rcu
#
# 11g repository creation utility for soa suite, webcenter
#
# @example soa rcu
#
#  oradb::rcu{'DEV_PS6':
#    rcu_file       => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
#    product        => 'soasuite',
#    version        => '11.1.1.7',
#    oracle_home    => '/oracle/product/11.2/db',
#    user           => 'oracle',
#    group          => 'dba',
#    download_dir   => '/install',
#    action         => 'create',
#    db_server      => 'dbagent1.alfa.local:1521',
#    db_service     => 'test.oracle.com',
#    sys_password   => 'Welcome01',
#    schema_prefix  => 'DEV',
#    repos_password => 'Welcome02',
#  }
#
# @param version Oracle installation version
# @param rcu_file filename of the installation software
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param puppet_download_mnt_point the location where the installation software is available
# @param remote_file the installation is remote accessiable or not
# @param product kind of rcu, for which oracle product
# @param log_output log all output
# @param download_dir location for installation files used by this module
# @param action rcu action on the database
# @param db_server the database server
# @param db_service the database service name
# @param sys_user the sys username
# @param sys_password the sys username password
# @param schema_prefix prefix of the rcu schemas
# @param repos_password the rcu schemas password
# @param temp_tablespace shared temp tablespace used by the rcu schemas
#
define oradb::rcu(
  String $rcu_file                                            = undef,
  Enum['soasuite', 'webcenter', 'oam', 'oim', 'all'] $product = 'soasuite',
  String $version                                             = '11.1.1.7',
  Optional[String] $oracle_home                               = undef,
  String $user                                                = lookup('oradb::user'),
  String $group                                               = lookup('oradb::group'),
  String $download_dir                                        = lookup('oradb::download_dir'),
  Enum['delete', 'create'] $action                            = 'create',
  String $db_server                                           = undef,
  String $db_service                                          = undef,
  String $sys_user                                            = 'sys',
  String $sys_password                                        = undef,
  String $schema_prefix                                       = undef,
  String $repos_password                                      = undef,
  Optional[String] $temp_tablespace                           = undef,
  String $puppet_download_mnt_point                           = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                                        = true,
  Boolean $log_output                                         = false,
){
  $exec_path = lookup('oradb::exec_path')

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
      command   => "unzip -o ${source}/${rcu_file} -d ${download_dir}/rcu_${version}",
      creates   => "${download_dir}/rcu_${version}/rcuHome",
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => $log_output,
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
    $components_passwords = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password]
  } elsif $product == 'webcenter' {
    $components           = '-component MDS -component OPSS -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $components_passwords = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oam' {
    $components           = '-component MDS -component OPSS -component IAU -component OAM'
    $components_passwords = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oim' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component IAU -component BIPLATFORM -component OIF -component OIM -component OAM -component OAAM -component OMSM'
    $components_passwords = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password,$repos_password, $repos_password, $repos_password,$repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'all' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $components_passwords = [ $repos_password, $repos_password, $repos_password,$repos_password,$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } else {
    fail('Unrecognized FMW product')
  }

  file { "${download_dir}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure  => present,
    require => Exec["extract ${rcu_file}"],
    content => epp('oradb/rcu_passwords.txt.epp',
                    { 'sys_password'        => $sys_password,
                      'componentsPasswords' => $components_passwords } ),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  if ( $oracle_home != undef ) {
    $pre_command    = "export SQLPLUS_HOME=${oracle_home};export RCU_LOG_LOCATION=${download_dir}/rcu_${version}/log;${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  } else {
    $pre_command    = "export RCU_LOG_LOCATION=${download_dir}/rcu_${version}/log;${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  }
  $post_command     = "-databaseType ORACLE -connectString ${db_server}:${db_service} -dbUser ${sys_user} -dbRole SYSDBA -schemaPrefix ${schema_prefix} ${components} "
  $password_command = " -f < ${download_dir}/rcu_${version}/rcu_passwords_${title}.txt"

  #optional set the Temp tablespace
  if $temp_tablespace == undef {
    $create_command  = "${pre_command} -createRepository ${post_command} ${password_command}"
  } else {
    $create_command  = "${pre_command} -createRepository ${post_command} -tempTablespace ${temp_tablespace} ${password_command}"
  }
  $delete_command  = "${pre_command} -dropRepository ${post_command} ${password_command}"

  if $action == 'create' {
    $statement = $create_command
  }
  elsif $action == 'delete' {
    $statement = $delete_command
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
