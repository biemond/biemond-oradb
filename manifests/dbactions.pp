# == Class: oradb::dbactions
#
#
# action        =  stop|start
#
#
define oradb::dbactions(
  $oracleHome  = undef,
  $user        = 'oracle',
  $group       = 'dba',
  $action      = 'start',
  $dbName      = 'orcl',
){
  case $::kernel {
    'Linux', 'SunOS': {
      $execPath    = "${oracleHome}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  db_control{"instance control ${title}":
    ensure                  => $action,   #running|start|abort|stop
    instance_name           => $dbName,
    oracle_product_home_dir => $oracleHome,
    os_user                 => $user,
  }

}