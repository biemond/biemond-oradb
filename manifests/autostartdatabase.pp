#
# autostartdatabase
#
# autostart of the nodemanager for linux & Solaris
#
# @example configuration
#
#  oradb::autostartdatabase{'dbora':
#    oracle_home  => '/opt/oracle/product/11g',
#    db_name      => 'ORCL',
#    user         => 'oracle',
#    service_name => 'dbora',
#  }
#
# @param oracle_home
# @param db_name
# @param user
# @param service_name
#
define oradb::autostartdatabase(
  String $oracle_home  = undef,
  String $db_name      = lookup('oradb::database_name'),
  String $user         = lookup('oradb::user'),
  String $service_name = lookup('oradb::host::service_name'),
){

  class { 'oradb::prepareautostart':
    oracle_home  => $oracle_home,
    user         => $user,
    service_name => $service_name,
  }

  $exec_path      = lookup('oradb::exec_path')
  $oratab         = lookup('oradb::oratab')
  $dbora_location = lookup('oradb::dbora_dir')

  case $facts['kernel'] {
    'Linux': {
      $sed_command = "sed -i -e's/:N/:Y/g' ${oratab}"
    }
    'SunOS': {
      $sed_command = "sed -e's/:N/:Y/g' ${oratab} > /tmp/oratab.tmp && mv /tmp/oratab.tmp ${oratab}"
    }
    default: {
      fail('Unrecognized operating system, please use it on a Linux or SunOS host')
    }
  }

  exec { "set dbora ${db_name}:${oracle_home}":
    command   => $sed_command,
    unless    => "/bin/grep '^${db_name}:${oracle_home}:Y' ${oratab}",
    require   => File["${dbora_location}/dbora"],
    path      => $exec_path,
    logoutput => true,
  }

}

