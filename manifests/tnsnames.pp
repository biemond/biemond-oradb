# == Class: oradb::tnsnames
#
#
define oradb::tnsnames(
  $oracle_home          = undef,
  $user                 = 'oracle',
  $group                = 'dba',
  $server               = {myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  $loadbalance          = 'ON',
  $failover             = 'ON',
  $connect_service_name = undef,
  $connect_server       = 'DEDICATED',
  $entry_type           = 'tnsname',
)
{
  if ! defined(Concat["${oracle_home}/network/admin/tnsnames.ora"]) {
    concat { "${oracle_home}/network/admin/tnsnames.ora":
      ensure         => present,
      owner          => $user,
      group          => $group,
      mode           => '0774',
      ensure_newline => true,
    }
  }

  case $entry_type {
    'tnsname'  : { $template_path = 'oradb/tnsnames.erb' }
    'listener' : { $template_path = 'oradb/listener.erb' }
    default    : { fail("${entry_type} is not a supported entry_type") }
  }

  concat::fragment { $title:
    target  => "${oracle_home}/network/admin/tnsnames.ora",
    content => template($template_path),
  }
}
