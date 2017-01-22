# == Class: oradb::dbactions
#
#
# action        =  stop|start|mount
#
#
define oradb::dbactions(
  Enum["database", "grid", "asm"] $db_type          = 'database',
  Optional[String] $oracle_home                     = undef,
  String $user                                      = lookup('oradb::user'),
  String $group                                     = lookup('oradb::group'),
  Enum["start", "stop", "running", "abort"] $action = 'start',
  String $db_name                                   = lookup('oradb::database_name'),
  String $provider                                  = 'sqlplus',
){
  if ( $db_type in ['grid','asm'] and $provider != 'srvctl') {
    fail('Provider must be srvctl if db_type is grid or asm')
  }
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
    os_user                 => $user,
    db_type                 => $db_type,
  }
}
