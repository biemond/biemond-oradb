# == Define: orautils::nodemanagerautostart
#
#  autostart of the nodemanager for linux
#
define oradb::autostartdatabase(
  $oracle_home  = undef,
  $db_name      = undef,
  $user         = 'oracle',
  $service_name = 'dbora',
){

  class { 'oradb::prepareautostart':
    oracle_home  => $oracle_home,
    user         => $user,
    service_name => $service_name,
  }

  $execPath    = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

  case $::kernel {
    'Linux': {
      $oraTab = '/etc/oratab'
      $dboraLocation = '/etc/init.d'
      $sedCommand = "sed -i -e's/:N/:Y/g' ${oraTab}"
    }
    'SunOS': {
      $oraTab = '/var/opt/oracle/oratab'
      $dboraLocation = '/etc'
      $sedCommand = "sed -e's/:N/:Y/g' ${oraTab} > /tmp/oratab.tmp && mv /tmp/oratab.tmp ${oraTab}"
    }
    default: {
      fail('Unrecognized operating system, please use it on a Linux or SunOS host')
    }
  }

  exec { "set dbora ${db_name}:${oracle_home}":
    command   => $sedCommand,
    unless    => "/bin/grep '^${db_name}:${oracle_home}:Y' ${oraTab}",
    require   => File["${dboraLocation}/dbora"],
    path      => $execPath,
    logoutput => true,
  }

}

