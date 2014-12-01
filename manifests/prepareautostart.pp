# == Class: oradb::prepareautostart
#
#  prepare autostart of the nodemanager for linux
#
class oradb::prepareautostart
{
  $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

  case $::kernel {
    'Linux': {
      $dboraLocation = '/etc/init.d'
    }
    'SunOS': {
      $dboraLocation = '/etc'
    }
    default: {
      fail('Unrecognized operating system, please use it on a Linux or SunOS host')
    }
  }

  file { "${dboraLocation}/dbora" :
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    content => regsubst(template("oradb/dbora_${::kernel}.erb"), '\r\n', "\n", 'EMG'),
  }

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OracleLinux': {
      exec { 'chkconfig dbora':
        command   => 'chkconfig --add dbora',
        require   => File['/etc/init.d/dbora'],
        user      => 'root',
        unless    => "chkconfig | /bin/grep 'dbora'",
        path      => $execPath,
        logoutput => true,
      }
    }
    'Ubuntu', 'Debian', 'SLES':{
      exec { 'update-rc.d dbora':
        command   => 'update-rc.d dbora defaults',
        require   => File['/etc/init.d/dbora'],
        user      => 'root',
        unless    => "ls /etc/rc3.d/*dbora | /bin/grep 'dbora'",
        path      => $execPath,
        logoutput => true,
      }
    }
    'Solaris': {
      file { '/tmp/oradb_smf.xml' :
        ensure  => present,
        mode    => '0755',
        owner   => 'root',
        content => template('oradb/oradb_smf.xml.erb'),
      }
      exec { 'chkconfig dbora':
        command   => 'svccfg -v import /tmp/oradb_smf.xml',
        require   => [File['/tmp/oradb_smf.xml'],File["${dboraLocation}/dbora"],],
        user      => 'root',
        unless    => 'svccfg list | grep oracledatabase',
        path      => $execPath,
        logoutput => true,
      }
    }
    default: {
      fail('Unrecognized operating system, please use it on a Linux or SunOS host')
    }
  }
}
