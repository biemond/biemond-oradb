# == Class: oradb::net
#
define oradb::net(
  $oracleHome   = undef,
  $version      = '11.2',
  $user         = 'oracle',
  $group        = 'dba',
  $downloadDir  = '/install',
  $dbPort       = '1521',
){
  if $version in ['11.2','12.1'] {
  } else {
    fail('Unrecognized version')
  }

  $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

  file { "${downloadDir}/netca_${version}.rsp":
    ensure  => present,
    content => template("oradb/netca_${version}.rsp.erb"),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  exec { "install oracle net ${title}":
    command     => "${oracleHome}/bin/netca /silent /responsefile ${downloadDir}/netca_${version}.rsp",
    require     => File["${downloadDir}/netca_${version}.rsp"],
    creates     => "${oracleHome}/network/admin/listener.ora",
    path        => $execPath,
    user        => $user,
    group       => $group,
    environment => ["USER=${user}",],
    logoutput   => true,
  }
}
