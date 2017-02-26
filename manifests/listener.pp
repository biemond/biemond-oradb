#
# listener
#
# Oracle listener control
#
# @example listener configuration
#
#  oradb::listener{'start listener':
#    action        => 'start',
#    oracle_base   => '/oracle',
#    oracle_home   => '/oracle/product/11.2/db',
#    user          => 'oracle',
#    group         => 'dba',
#    listener_name => 'listener',
#  }
#
# @param oracle_base full path to the Oracle Base directory
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param action listener control action
# @param listener_name the name of the listener
#
define oradb::listener( String $oracle_base                               = undef,
                        String $oracle_home                               = undef,
                        String $user                                      = lookup('oradb::user'),
                        String $group                                     = lookup('oradb::group'),
                        Enum['running', 'start', 'abort', 'stop'] $action = 'start',
                        String $listener_name                             = 'listener',
)
{

  db_listener{ $title:
    ensure          => $action,
    oracle_base_dir => $oracle_base,
    oracle_home_dir => $oracle_home,
    os_user         => $user,
    listener_name   => $listener_name,
  }
}
