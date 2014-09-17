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

  case $::kernel {
    'Linux': {
      $execPath    = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  exec { "set dbora ${dbName}:${oracleHome}":
    command   => "sed -i -e's/:N/:Y/g' /etc/oratab",
    unless    => "/bin/grep '^${dbName}:${oracleHome}:Y' /etc/oratab",
    require   => File['/etc/init.d/dbora'],
    path      => $execPath,
    logoutput => true,
  }

}

