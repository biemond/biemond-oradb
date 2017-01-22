#
# = Class: oradb::tnsnames
#
define oradb::tnsnames(
  String $oracle_home                    = undef,
  String $user                           = lookup('oradb::user'),
  String $group                          = lookup('oradb::group'),
  Hash   $server                         = { myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  String $loadbalance                    = 'ON',
  String $failover                       = 'ON',
  Optional[String] $connect_service_name = undef,
  String $connect_server                 = 'DEDICATED',
  String $entry_type                     = 'tnsname',
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
    'tnsname'  : { $template_path = 'oradb/tnsnames.epp' }
    'listener' : { $template_path = 'oradb/listener.epp' }
    default    : { fail("${entry_type} is not a supported entry_type") }
  }

  $size = keys($server).size

  # puppet epp render tnsnames.epp --values "{size => 1 ,title => 'a', server => { myserver => { host => 'dbcdb.example.com',  port => '1525', protocol => 'TCP' }} , loadbalance => 'ON', failover => 'ON' , connect_server => 'aa' , connect_service_name => 'aaa' }"
  # puppet epp render tnsnames.epp --values "{size => 2 , title => 'a', server => { myserver => { host => 'dbcdb.example.com', port => '1525', protocol => 'TCP' }, myserver2 =>  { host => 'dbcdb.example.com', port => '1526', protocol => 'TCP' }  } , loadbalance => 'ON', failover => 'ON' , connect_server => 'aa' , connect_service_name => 'aaa' }"
  concat::fragment { $title:
    target  => "${oracle_home}/network/admin/tnsnames.ora",
    content => epp($template_path , { 'title'                => $title,
                                      'server'               => $server,
                                      'loadbalance'          => $loadbalance,
                                      'failover'             => $failover,
                                      'connect_server'       => $connect_server,
                                      'connect_service_name' => $connect_service_name,
                                      'size'                 => $size
                                      }),
  }
}
