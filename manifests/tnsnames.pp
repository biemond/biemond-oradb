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
# @param connect_timeout the timeout duration in seconds for a client to establish an Oracle Net connection to an Oracle database
# @param transport_connect_timeout the transportation timeout duration in seconds for a client to establish an Oracle Net connection to an Oracle Database
# @param retry_count The number of times an ADDRESS list is traversed before the connection attempt is terminated. The default value is 0.
# @param entry_type type of configuration
#
define oradb::tnsnames(
  String $oracle_home                          = undef,
  String $user                                 = lookup('oradb::user'),
  String $group                                = lookup('oradb::group'),
  Hash   $server                               = { myserver => { host => undef, port => '1521', protocol => 'TCP' }},
  String $loadbalance                          = 'ON',
  String $failover                             = 'ON',
  Optional[String] $connect_service_name       = undef,
  String $connect_server                       = 'DEDICATED',
  Optional[Integer] $connect_timeout           = undef,
  Optional[Integer] $transport_connect_timeout = undef,
  Optional[Integer] $retry_count               = undef,
  Enum['tnsnames','listener'] $entry_type      = 'tnsnames',
)
{
  if ! defined(Concat['tnsnames.ora']) {
    concat { 'tnsnames.ora':
      ensure         => present,
      path           => "${oracle_home}/network/admin/tnsnames.ora",
      owner          => $user,
      group          => $group,
      mode           => '0774',
      ensure_newline => true,
    }

    # Include the "Managed by Puppet" fragment.  This will be added only
    # once due to the behavor of 'include' (below).
    include oradb::tnsnames::header

  }

  case $entry_type {
    'tnsnames' : { $template_path = 'oradb/tnsnames.epp' }
    'listener' : { $template_path = 'oradb/listener.epp' }
    default    : { fail("${entry_type} is not a supported entry_type") }
  }

  concat::fragment { $title:
    target  => 'tnsnames.ora',
    content => epp($template_path , { 'title'                     => $title,
                                      'server'                    => $server,
                                      'loadbalance'               => $loadbalance,
                                      'failover'                  => $failover,
                                      'connect_server'            => $connect_server,
                                      'connect_service_name'      => $connect_service_name,
                                      'connect_timeout'           => $connect_timeout,
                                      'transport_connect_timeout' => $transport_connect_timeout,
                                      'retry_count'               => $retry_count,
                                      }),
  }
}
