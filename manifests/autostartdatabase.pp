# == Define: orautils::nodemanagerautostart
#
#  autostart of the nodemanager for linux
#
define oradb::autostartdatabase(
  $oracleHome  = undef,
  $dbName      = undef,
  $user        = 'oracle',
){
  include oradb::prepareautostart

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

  exec { "set dbora ${dbName}:${oracleHome}":
    command   => $sedCommand,
    unless    => "/bin/grep '^${dbName}:${oracleHome}:Y' ${oraTab}",
    require   => File["${dboraLocation}/dbora"],
    path      => $execPath,
    logoutput => true,
  }

}

