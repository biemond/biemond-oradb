# == Class: oradb::dbactions
#
#
# action        =  stop|start|mount
#
#
define oradb::dbactions(
  $db_type     = 'database',
  $oracle_home = undef,
  $user        = 'oracle',
  $group       = 'dba',
  $action      = 'start',
  $db_name     = 'orcl',
  $provider    = 'sqlplus',
){
  if ( $db_type in ['grid','asm'] and $provider != 'srvctl') {fail('Provider must be srvctl if db_type is grid or asm') }
  if ( $db_type in ['grid','asm'] and !($action in ['running','start','abort','stop'])) {
    fail('Unrecognized action for db_type grid and asm, use running, start, abort or stop')
  }
  if ( $db_type == 'database' and !($action in ['running','start','abort','stop','mount'])) {
    fail('Unrecognized action for db_type grid and asm, use running, start, abort, stop or mount')
  }

  db_control{"instance control ${title}":
    ensure                  => $action,
    provider                => $provider,
    instance_name           => $db_name,
    oracle_product_home_dir => $oracle_home,
    grid_product_home_dir   => $grid_home,
    os_user                 => $user,
    db_type                 => $db_type,
  }
}
