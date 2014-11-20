# == Class: oradb::tnsnames
#
#
define oradb::tnsnames(
  $oracleHome         = undef,
  $user               = 'oracle',
  $group              = 'dba',
  $server             = {myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  $loadbalance        = 'ON',
  $failover           = 'ON',
  $connectServiceName = undef,
  $connectServer      = 'DEDICATED',
)
{
  if ! defined(Concat["${oracleHome}/network/admin/tnsnames.ora"]) {
    concat { "${oracleHome}/network/admin/tnsnames.ora":
      ensure         => present,
      owner          => $user,
      group          => $group,
      mode           => '0774',
      ensure_newline => true,
    }
  }

  concat::fragment { $title:
    target  => "${oracleHome}/network/admin/tnsnames.ora",
    content => template('oradb/tnsnames.erb'),
  }
}
