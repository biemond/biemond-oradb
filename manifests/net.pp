# == Class: oradb::net
#
define oradb::net(
  $oracle_home  = undef,
  $version      = '11.2',
  $user         = 'oracle',
  $group        = 'dba',
  $download_dir = '/install',
  $db_port      = '1521',
){
  if $version in ['11.2','12.1'] {
  } else {
    fail('Unrecognized version')
  }

  $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

  file { "${download_dir}/netca_${version}.rsp":
    ensure  => present,
    content => template("oradb/netca_${version}.rsp.erb"),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  exec { "install oracle net ${title}":
    command     => "${oracle_home}/bin/netca /silent /responsefile ${download_dir}/netca_${version}.rsp",
    require     => File["${download_dir}/netca_${version}.rsp"],
    creates     => "${oracle_home}/network/admin/listener.ora",
    path        => $execPath,
    user        => $user,
    group       => $group,
    environment => ["USER=${user}",],
    logoutput   => true,
  }
}
