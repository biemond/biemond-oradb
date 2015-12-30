# == Class: oradb::dbactions
#
#
# action        =  stop|start
#
#
define oradb::dbactions(
  $db_type     = 'database',
  $oracle_home = undef,
  $grid_home   = undef,
  $user        = 'oracle',
  $group       = 'dba',
  $action      = 'start',
  $db_name     = 'orcl',
){
  if $db_type == 'database' {
    db_control{"instance control ${title}":
      ensure                  => $action,   #running|start|abort|stop
      instance_name           => $db_name,
      oracle_product_home_dir => $oracle_home,
      os_user                 => $user,
    }
  } elsif $db_type in ['grid','asm'] {
    db_control{'instance control ${title}':
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