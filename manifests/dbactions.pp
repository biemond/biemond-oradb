# == Class: oradb::dbactions
#
#
# action        =  stop|start
#
#
define oradb::dbactions(
  $oracle_home = undef,
  $user        = 'oracle',
  $group       = 'dba',
  $action      = 'start',
  $db_name     = 'orcl',
){
  db_control{"instance control ${title}":
    ensure                  => $action,   #running|start|abort|stop
    instance_name           => $db_name,
    oracle_product_home_dir => $oracle_home,
    os_user                 => $user,
  }
}