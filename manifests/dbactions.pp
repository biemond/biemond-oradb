# == Class: oradb::dbactions
#
#
# action        =  stop|start
#
#
define oradb::dbactions(
  Enum["database", "grid", "asm"] $db_type     = 'database',
  $oracle_home = undef,
  $grid_home   = undef,
  String $user        = lookup('oradb::user'),
  String $group       = lookup('oradb::group'),
  Enum["start", "stop", "running", "abort"] $action      = 'start',
  String $db_name     = lookup('oradb::database_name'),
){
  if $db_type == 'database' {
    db_control{"instance control ${title}":
      ensure                  => $action,   #running|start|abort|stop
      instance_name           => $db_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => $user,
    }
  } elsif $db_type in ['grid','asm'] {
    db_control{"instance control ${title}":
      ensure                  => $action,   #running|start|abort|stop
      provider                => 'srvctl',
      instance_name           => $db_name,
      oracle_product_home_dir => $oracle_home,
      grid_product_home_dir   => $grid_home,
      os_user                 => $user,
      db_type                 => 'grid',
    }
  }
}
