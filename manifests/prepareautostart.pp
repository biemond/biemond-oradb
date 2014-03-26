# == Class: oradb::prepareautostart
#
#  prepare autostart of the nodemanager for linux
#

class oradb::prepareautostart
{
  case $::kernel {
    Linux: {
      $execPath    = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      Exec { path  => $execPath,
        logoutput  => true,
      }
    }
    default: {
      fail("Unrecognized operating system")
    }
  }
  
  file { "/etc/init.d/dbora" :
    ensure         => present,
    mode           => "0755",
    owner          => 'root',
    content        => template("oradb/dbora.erb"),
  }

  case $operatingsystem {
    CentOS, RedHat, OracleLinux: {

      exec { "chkconfig dbora":
        command        => "chkconfig --add dbora",
        require        => File["/etc/init.d/dbora"],
        user           => 'root',
        unless         => "chkconfig | /bin/grep 'dbora'",
      }
    }
    Ubuntu, Debian, SLES:{

      exec { "update-rc.d dbora":
        command        => "update-rc.d dbora defaults",
        require        => File["/etc/init.d/dbora"],
        user           => 'root',
        unless         => "ls /etc/rc3.d/*dbora | /bin/grep 'dbora'",
      }      
    }
    default: {
      fail("Unrecognized operating system")
    }    
  }
}
