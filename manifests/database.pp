# == Class: oradb::database
#
define oradb::database(
  String $oracle_base               = undef,
  String $oracle_home               = undef,
  String $version                   = lookup('oradb::version'),
  String $user                      = lookup('oradb::user'),
  String $group                     = lookup('oradb::group'),
  String $download_dir              = lookup('oradb::download_dir'),
  String $action                    = lookup('oradb::database::action'),
  $template                         = undef,
  $template_seeded                  = undef,
  $template_variables               = 'dummy=/tmp', # for dbt template
  String $db_name                   = lookup('oradb::database_name'),
  String $db_domain                 = undef,
  Integer $db_port                  = lookup('oradb::listener_port'),
  String $sys_password              = lookup('oradb::default::password'),
  String $system_password           = lookup('oradb::default::password'),
  $data_file_destination            = undef,
  $recovery_area_destination        = undef,
  String $character_set             = lookup('oradb::database::character_set'),
  String $nationalcharacter_set     = lookup('oradb::database::nationalcharacter_set'),
  $init_params                      = undef,
  String $sample_schema             = lookup('oradb::database::sample_schema'),
  Integer $memory_percentage        = lookup('oradb::database::memory_percentage'),
  Integer $memory_total             = lookup('oradb::database::memory_total'),
  Enum["MULTIPURPOSE", "DATA_WAREHOUSING", "OLTP"] $database_type = lookup('oradb::database::database_type'),
  Enum["NONE", "CENTRAL", "LOCAL", "ALL"] $em_configuration = lookup('oradb::database::em_configuration'),
  Enum["FS", "CFS", "ASM"] $storage_type = lookup('oradb::database::storage_type'),
  String $asm_snmp_password         = lookup('oradb::default::password'),
  String $db_snmp_password          = lookup('oradb::default::password'),
  String $asm_diskgroup             = lookup('oradb::database::asm_diskgroup'),
  $recovery_diskgroup               = undef,
  $cluster_nodes                    = undef, # comma separated list with at first the local and at second the remode host e.g. "racnode1,racnode2"
  Boolean $container_database       = false, # 12.1 feature for pluggable database
  String $puppet_download_mnt_point = lookup('oradb::module_mountpoint'),
)
{
  if ( $version in lookup('oradb::database_versions') == false ) {
    fail('Unrecognized version for oradb::database')
  }

  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $::kernel in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
  }

  if $action == 'create' {
    $operationType = 'createDatabase'
  } elsif $action == 'delete' {
    $operationType = 'deleteDatabase'
  } else {
    fail('Unrecognized database action')
  }

  if ( $database_type in lookup('oradb::instance_types') == false ) {
    fail('Unrecognized database_type')
  }

  if ( $em_configuration in lookup('oradb::instance_em_configuration') == false) {
    fail('Unrecognized emConfiguration')
  }

  if ( $storage_type in lookup('oradb::instance_storage_type') == false ) {
    fail('Unrecognized storageType')
  }

  if ( $version == '11.2' and $container_database == true ){
    fail('container or pluggable database is not supported on version 11.2')
  }

  $exec_path = lookup('oradb::exec_path')
  $user_base = lookup('oradb::user_base_dir')
  $user_home = "${user_base}/${user}"

  if (is_hash($init_params) or is_string($init_params)) {
    if is_hash($init_params) {
      $initParamsArray = sort(join_keys_to_values($init_params, '='))
      $sanitizedInitParams = join($initParamsArray,',')
    } else {
      $sanitizedInitParams = $init_params
    }
  } else {
    fail 'init_params only supports a String or a Hash as value type'
  }

  $sanitized_title = regsubst($title, '[^a-zA-Z0-9.-]', '_', 'G')

  if $db_domain {
    $globaldb_name = "${db_name}.${db_domain}"
  } else {
    $globaldb_name = $db_name
  }

  if ! defined(File["${download_dir}/database_${sanitized_title}.rsp"]) {
    file { "${download_dir}/database_${sanitized_title}.rsp":
      ensure  => present,
      content => template("oradb/dbca_${version}.rsp.erb"),
      mode    => '0770',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
  }

  if ( $template_seeded ) {
    $templatename = "${oracle_home}/assistants/dbca/templates/${template_seeded}.dbc"
  } elsif ( $template ) {
    $templatename = "${download_dir}/${template}_${sanitized_title}.dbt"
    file { $templatename:
      ensure  => present,
      content => template("${puppet_download_mnt_point}/${template}.dbt.erb"),
      mode    => '0775',
      owner   => $user,
      group   => $group,
      before  => Exec["oracle database ${title}"],
    }
  } else {
    $templatename = undef
  }

  if $action == 'create' {
    if ( $templatename ) {
      if ( $version == '11.2' or $container_database == false ) {
        if ( $cluster_nodes != undef) {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes} -variables ${template_variables}"
        } else {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -variables ${template_variables}"
        }
      } else {
        if( $cluster_nodes != undef) {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes} -variables ${template_variables}"
        } else {
          $command = "${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -variables ${template_variables}"
        }
      }
    } else {
      $command = "${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp"
    }
    exec { "oracle database ${title}":
      command     => $command,
      creates     => "${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $exec_path,
      user        => $user,
      group       => $group ,
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  } elsif $action == 'delete' {
    exec { "oracle database ${title}":
      command     => "${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp",
      onlyif      => "ls ${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $exec_path,
      user        => $user,
      group       => $group ,
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  }
}
