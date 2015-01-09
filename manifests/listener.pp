# == Class: oradb::listener
#
#
define oradb::listener( $oracleBase  = undef,
                        $oracleHome  = undef,
                        $user        = 'oracle',
                        $group       = 'dba',
                        $action      = 'start',
)
{
  if (!( $action in ['running','start','abort','stop'])){
    fail('Unrecognized action, use running|start|abort|stop')
  }

  db_listener{ $title:
    ensure          => $action,
    oracle_base_dir => $oracleBase,
    oracle_home_dir => $oracleHome,
    os_user         => $user,
  }
}