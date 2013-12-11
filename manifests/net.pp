# == Class: oradb::net
#
#
#
#
#
define oradb::net( $oracleHome   = undef,
                   $version      = "11.2",
                   $user         = 'oracle',
                   $group        = 'dba',
                   $downloadDir  = '/install',
)

{
  if $version == "11.2" or $version == "12.1" {
  } else {
    fail("Unrecognized version")
  }

  case $::kernel {
    Linux, SunOS:  {
      $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
      $path        = $downloadDir

      Exec { path  => $execPath,
        user       => $user,
        group      => $group,
        logoutput  => true,
      }
      File {
        ensure     => present,
        mode       => 0775,
        owner      => $user,
        group      => $group,
      }
    }
    default: {
      fail("Unrecognized operating system")
    }
  }

  if ! defined(File["${path}/netca_${version}.rsp"]) {
    if ! defined(File["${path}"]) {
      file { "${path}":
        ensure       => directory,
      }
    }
    file { "${path}/netca_${version}.rsp":
      ensure       => present,
      content      => template("oradb/netca_${version}.rsp.erb"),
      require      => File["${path}"],
    }
  }

  exec { "install oracle net ${title}":
    command        => "netca /silent /responsefile ${path}/netca_${version}.rsp",
    require        => File["${path}/netca_${version}.rsp"],
    creates        => "${oracleHome}/network/admin/listener.ora",
  }
}
