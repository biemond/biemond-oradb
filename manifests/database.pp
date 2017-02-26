#
# database
#
# add or destroys a (container) database
#
# @example creates a database
#
#    oradb::database{ 'testDb':
#      oracle_base               => '/oracle',
#      oracle_home               => '/oracle/product/11.2/db',
#      version                   => '11.2',
#      user                      => 'oracle',
#      group                     => 'dba',
#      download_dir              => '/var/tmp/install',
#      action                    => 'create',
#      db_name                   => 'test',
#      db_domain                 => 'oracle.com',
#      db_port                   => '1521',
#      sys_password              => 'Welcome01',
#      system_password           => 'Welcome01',
#      data_file_destination     => "/oracle/oradata",
#      recovery_area_destination => "/oracle/flash_recovery_area",
#      character_set             => "AL32UTF8",
#      nationalcharacter_set     => "UTF8",
#      init_params               => {'open_cursors'        => '1000',
#                                    'processes'           => '600',
#                                    'job_queue_processes' => '4' },
#      sample_schema             => 'TRUE',
#      memory_percentage         => 40,
#      memory_total              => 800,
#      database_type             => "MULTIPURPOSE",
#      em_configuration          => "NONE",
#    }
#
#    oradb::database{ 'oraDb':
#      oracle_base               => '/oracle',
#      oracle_home               => '/oracle/product/12.1/db',
#      version                   => '12.1',
#      user                      => 'oracle',
#      group                     => 'dba'
#      download_dir              => '/var/tmp/install',
#      action                    => 'create',
#      db_name                   => 'orcl',
#      db_domain                 => 'example.com',
#      sys_password              => 'Welcome01',
#      system_password           => 'Welcome01',
#      character_set             => 'AL32UTF8',
#      nationalcharacter_set     => 'UTF8',
#      sample_schema             => 'FALSE',
#      memory_percentage         => 40,
#      memory_total              => 800,
#      database_type             => 'MULTIPURPOSE',
#      em_configuration          => 'NONE',
#      data_file_destination     => '/oracle/oradata',
#      recovery_area_destination => '/oracle/flash_recovery_area',
#      init_params               => {'open_cursors'        => '1000',
#                                    'processes'           => '600',
#                                    'job_queue_processes' => '4' },
#      container_database        => true,
#    }
#
# @param oracle_base full path to the Oracle Base directory
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param db_port database listener port number
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param download_dir location for installation files used by this module
# @param puppet_download_mnt_point the location where the installation software is available
# @param version Oracle installation version
# @param action create or delete the database
# @param template dbt template for your own full database configution
# @param template_seeded seeded template name
# @param template_variables variables which you can use in your dbt template
# @param db_name database name
# @param db_domain database domain name
# @param sys_password sys username password
# @param system_password system username password
# @param data_file_destination full path to for the Datafiles location
# @param recovery_area_destination full path to for the recovery area destination location
# @param character_set
# @param nationalcharacter_set
# @param init_params database parameters
# @param sample_schema add sample schemas
# @param memory_percentage
# @param memory_total
# @param database_type
# @param em_configuration
# @param storage_type
# @param asm_snmp_password
# @param db_snmp_password
# @param asm_diskgroup
# @param recovery_diskgroup
# @param cluster_nodes
# @param container_database configure as a 12c container database which allows plugleable databases
#
define oradb::database(
  String $oracle_base                                             = undef,
  String $oracle_home                                             = undef,
  Enum['11.2', '12.1', '12.2'] $version                           = lookup('oradb::version'),
  String $user                                                    = lookup('oradb::user'),
  String $group                                                   = lookup('oradb::group'),
  String $download_dir                                            = lookup('oradb::download_dir'),
  Enum['create','delete'] $action                                 = lookup('oradb::database::action'),
  Optional[String] $template                                      = undef,
  Optional[String] $template_seeded                               = undef,
  String $template_variables                                      = 'dummy=/tmp', # for dbt template
  String $db_name                                                 = lookup('oradb::database_name'),
  String $db_domain                                               = undef,
  Integer $db_port                                                = lookup('oradb::listener_port'),
  String $sys_password                                            = lookup('oradb::default::password'),
  String $system_password                                         = lookup('oradb::default::password'),
  Optional[String] $data_file_destination                         = undef,
  Optional[String] $recovery_area_destination                     = undef,
  String $character_set                                           = lookup('oradb::database::character_set'),
  String $nationalcharacter_set                                   = lookup('oradb::database::nationalcharacter_set'),
  Optional[Hash] $init_params                                     = undef,
  String $sample_schema                                           = lookup('oradb::database::sample_schema'),
  Integer $memory_percentage                                      = lookup('oradb::database::memory_percentage'),
  Integer $memory_total                                           = lookup('oradb::database::memory_total'),
  Enum['MULTIPURPOSE', 'DATA_WAREHOUSING', 'OLTP'] $database_type = lookup('oradb::database::database_type'),
  Enum['NONE', 'CENTRAL', 'LOCAL', 'ALL'] $em_configuration       = lookup('oradb::database::em_configuration'),
  Enum['FS', 'CFS', 'ASM'] $storage_type                          = lookup('oradb::database::storage_type'),
  String $asm_snmp_password                                       = lookup('oradb::default::password'),
  String $db_snmp_password                                        = lookup('oradb::default::password'),
  String $asm_diskgroup                                           = lookup('oradb::database::asm_diskgroup'),
  Optional[String] $recovery_diskgroup                            = undef,
  Optional[String] $cluster_nodes                                 = undef, # comma separated list with at first the local and at second the remode host e.g. "racnode1,racnode2"
  Boolean $container_database                                     = false, # 12.1 feature for pluggable database
  String $puppet_download_mnt_point                               = lookup('oradb::module_mountpoint'),
)
{

  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $::kernel in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
  }

  if $action == 'create' {
    $operation_type = 'createDatabase'
  } elsif $action == 'delete' {
    $operation_type = 'deleteDatabase'
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
      $init_params_array = sort(join_keys_to_values($init_params, '='))
      $sanitized_init_params = join($init_params_array,',')
    } else {
      $sanitized_init_params = $init_params
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
      content => epp("oradb/dbca_${version}.rsp.epp",
                    { 'operationType'             => $operation_type,
                      'globaldb_name'             => $globaldb_name,
                      'db_name'                   => $db_name,
                      'cluster_nodes'             => $cluster_nodes,
                      'sys_password'              => $sys_password,
                      'system_password'           => $system_password,
                      'em_configuration'          => $em_configuration,
                      'db_snmp_password'          => $db_snmp_password,
                      'data_file_destination'     => $data_file_destination,
                      'recovery_area_destination' => $recovery_area_destination,
                      'storage_type'              => $storage_type,
                      'asm_diskgroup'             => $asm_diskgroup,
                      'asm_snmp_password'         => $asm_snmp_password,
                      'recovery_diskgroup'        => $recovery_diskgroup,
                      'character_set'             => $character_set,
                      'nationalcharacter_set'     => $nationalcharacter_set,
                      'sanitizedInitParams'       => $sanitized_init_params,
                      'sample_schema'             => $sample_schema,
                      'memory_percentage'         => $memory_percentage,
                      'database_type'             => $database_type,
                      'memory_total'              => $memory_total,
                      'db_port'                   => $db_port,
                      'container_database'        => $container_database }),
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

  $elevation_prefix = "su - ${user} -c \"/bin/ksh -c \\\""
  $elevation_suffix = "\\\"\""

  if $action == 'create' {
    if ( $templatename ) {
      if ( $version == '11.2' or $container_database == false ) {
        if ( $cluster_nodes != undef) {
          $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes} -variables ${template_variables}${elevation_suffix}"
        } else {
          $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -variables ${template_variables}${elevation_suffix}"
        }
      } else {
        if( $cluster_nodes != undef) {
          $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -nodelist ${cluster_nodes} -variables ${template_variables}${elevation_suffix}"
        } else {
          $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -createDatabase -templateName ${templatename} -gdbname ${globaldb_name} -characterSet ${character_set} -createAsContainerDatabase ${container_database} -responseFile NO_VALUE -sysPassword ${sys_password} -systemPassword ${system_password} -dbsnmpPassword ${db_snmp_password} -asmsnmpPassword ${asm_snmp_password} -storageType ${storage_type} -emConfiguration ${em_configuration} -variables ${template_variables}${elevation_suffix}"
        }
      }
    } else {
      if ( $version == '12.2' ) {
        $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -createDatabase -responseFile ${download_dir}/database_${sanitized_title}.rsp${elevation_suffix}"
      } else {
        $command = "${elevation_prefix}${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp${elevation_suffix}"
      }
    }
    exec { "oracle database ${title}":
      command     => $command,
      creates     => "${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $exec_path,
      user        => 'root',
      group       => 'root',
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  } elsif $action == 'delete' {
    if ( $version == '12.2' ) {
      $command = "${oracle_home}/bin/dbca -silent -deleteDatabase -sourceDB ${db_name} -sysDBAUserName sys -sysDBAPassword ${sys_password}"
    } else {
      $command = "${oracle_home}/bin/dbca -silent -responseFile ${download_dir}/database_${sanitized_title}.rsp"
    }
    exec { "oracle database ${title}":
      command     => $command,
      onlyif      => "ls ${oracle_base}/admin/${db_name}",
      timeout     => 0,
      path        => $exec_path,
      user        => $user,
      group       => $group,
      cwd         => $oracle_base,
      environment => ["USER=${user}",],
      logoutput   => true,
    }
  }
}
