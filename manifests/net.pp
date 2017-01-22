# == Class: oradb::net
#
define oradb::net(
  String $oracle_home  = undef,
  String $version      = lookup('oradb::version'),
  String $user         = lookup('oradb::user'),
  String $group        = lookup('oradb::group'),
  String $download_dir = lookup('oradb::download_dir'),
  Integer $db_port     = lookup('oradb::listener_port'),
){
  if ( $version in lookup('oradb::net_versions') == false ) {
    fail('Unrecognized version for oradb::net')
  }

  $exec_path = lookup('oradb::exec_path')

  file { "${download_dir}/netca_${version}.rsp":
    ensure  => present,
    content => epp("oradb/netca_${version}.rsp.epp", { 'db_port' => $db_port }),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  exec { "install oracle net ${title}":
    command     => "${oracle_home}/bin/netca /silent /responsefile ${download_dir}/netca_${version}.rsp",
    require     => File["${download_dir}/netca_${version}.rsp"],
    creates     => "${oracle_home}/network/admin/listener.ora",
    path        => $exec_path,
    user        => $user,
    group       => $group,
    environment => ["USER=${user}",],
    logoutput   => true,
  }
}
