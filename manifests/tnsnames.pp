#
# = Class: oradb::tnsnames
#
define oradb::tnsnames(
  String $oracle_home          = undef,
  String $user                 = undef,
  String $group                = undef,
  Hash   $server               = { myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  String $loadbalance          = 'ON',
  String $failover             = 'ON',
  String $connect_service_name = undef,
  String $connect_server       = 'DEDICATED',
  String $entry_type           = 'tnsname',
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
