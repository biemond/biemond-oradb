# == Class: oradb::listener
#
#
define oradb::listener( String $oracle_base   = undef,
                        String $oracle_home   = undef,
                        String $user          = lookup('oradb::user'),
                        String $group         = lookup('oradb::group'),
                        Enum["running", "start", "abort", "stop"] $action = 'start',
                        String $listener_name = 'listener',
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
