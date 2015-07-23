# == Class: oradb::listener
#
#
define oradb::listener( $oracle_base   = undef,
                        $oracle_home   = undef,
                        $user          = 'oracle',
                        $group         = 'dba',
                        $action        = 'start',
                        $listener_name = 'listener',
)
{
  if (!( $action in ['running','start','abort','stop'])){
    fail('Unrecognized action, use running|start|abort|stop')
  }

  db_listener{ $title:
    ensure          => $action,
    oracle_base_dir => $oracle_base,
    oracle_home_dir => $oracle_home,
    os_user         => $user,
    listener_name   => $listener_name,
  }
}
