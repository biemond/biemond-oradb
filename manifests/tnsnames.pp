#
# tnsnames
#
# Configure tnsnames entries
#
# @example tnsnames
#
#  oradb::tnsnames{'orcl':
#    oracle_home          => '/oracle/product/11.2/db',
#    user                 => 'oracle',
#    group                => 'dba',
#    server               => { myserver => { host => soadb.example.nl, port => '1521', protocol => 'TCP' }},
#    connect_service_name => 'soarepos.example.nl',
#  }
#
#  oradb::tnsnames{'test':
#    oracle_home          => '/oracle/product/11.2/db',
#    user                 => 'oracle',
#    group                => 'dba',
#    server               => { myserver => { host => soadb.example.nl, port => '1525', protocol => 'TCP' }, myserver2 => { host => soadb2.example.nl, port => '1526', protocol => 'TCP' }},
#    connect_service_name => 'soarepos.example.nl',
#    connect_server       => 'DEDICATED',
#  }
#
# @param oracle_home full path to the Oracle Home directory
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param server the tnsnames connection details
# @param loadbalance configure loadbalance on the tnsnames entries
# @param failover configure failover on the tnsnames entries
# @param connect_service_name the service name of the database
# @param connect_server service connection type
# @param entry_type type of configuration
#
define oradb::tnsnames(
  String $oracle_home                     = undef,
  String $user                            = lookup('oradb::user'),
  String $group                           = lookup('oradb::group'),
  Hash   $server                          = { myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  String $loadbalance                     = 'ON',
  String $failover                        = 'ON',
  Optional[String] $connect_service_name  = undef,
  String $connect_server                  = 'DEDICATED',
  Enum['tnsnames','listener'] $entry_type = 'tnsnames',
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
    'tnsnames' : { $template_path = 'oradb/tnsnames.epp' }
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
