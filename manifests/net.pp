#
# net
#
# Configure Oracle Net
#
# @example net configuration
#
#  oradb::net{ 'config net8':
#    oracle_home   => '/oracle/product/11.2/db',
#    version       => '12.1,
#    user          => 'oracle',
#    group         => 'dba',
#    download_dir  => '/var/tmp/install',
#    db_port       => '1521',
#  }
#
# @param version Oracle installation version
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param download_dir location for installation files used by this module
# @param db_port the listener port
#
define oradb::net(
  String $oracle_home                   = undef,
  Enum['11.2', '12.1', '12.2'] $version = lookup('oradb::version'),
  String $user                          = lookup('oradb::user'),
  String $group                         = lookup('oradb::group'),
  String $download_dir                  = lookup('oradb::download_dir'),
  Integer $db_port                      = lookup('oradb::listener_port'),
){
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
