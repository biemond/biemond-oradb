# == Class: oradb::prepareautostart
#
#  prepare autostart of the nodemanager for linux
#
class oradb::prepareautostart(
  String $oracle_home  = undef,
  String $user         = lookup('oradb::user'),
  String $service_name = lookup('oradb::host::service_name'),
){
  $exec_path     = lookup('oradb::exec_path')
  $dboraLocation = lookup('oradb::dbora_dir')

  file { "${dboraLocation}/${service_name}" :
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    content => regsubst(epp("oradb/dbora_${::kernel}.epp", { 'oracle_home' => $oracle_home,
                                                             'user' => $user,
                                                             'service_name' => $service_name } ), '\r\n', "\n", 'EMG'),
  }

  case $facts['operatingsystem'] {
    'CentOS', 'RedHat', 'OracleLinux', 'SLES': {
      exec { "enable service ${service_name}":
        command   => "chkconfig --add ${service_name}",
        require   => File["/etc/init.d/${service_name}"],
        user      => 'root',
        unless    => "chkconfig --list | /bin/grep \'${service_name}\'",
        path      => $exec_path,
        logoutput => true,
      }
    }
    'Ubuntu', 'Debian':{
      exec { "enable service ${service_name}":
        command   => "update-rc.d ${service_name} defaults",
        require   => File["/etc/init.d/${service_name}"],
        user      => 'root',
        unless    => "ls /etc/rc3.d/*${service_name} | /bin/grep \'${service_name}\'",
        path      => $exec_path,
        logoutput => true,
      }
    }
    'Solaris': {
      file { '/tmp/oradb_smf.xml' :
        ensure  => present,
        mode    => '0755',
        owner   => 'root',
        content => epp('oradb/oradb_smf.xml.epp', { 'dboraLocation' => $dboraLocation , 'service_name' => $service_name }),
      }
      exec { "enable service ${service_name}":
        command   => 'svccfg -v import /tmp/oradb_smf.xml',
        require   => File['/tmp/oradb_smf.xml',"${dboraLocation}/${service_name}"],
        user      => 'root',
        unless    => 'svccfg list | grep oracledatabase',
        path      => $exec_path,
        logoutput => true,
      }
    }
    default: {
      fail('Unrecognized operating system, please use it on a Linux or SunOS host')
    }
  }
}
