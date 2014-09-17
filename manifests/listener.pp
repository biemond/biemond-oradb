# == Class: oradb::listener
#
#
#    oradb::listener{'start listener':
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            user         => 'oracle',
#            group        => 'dba',
#            action       => 'start',
#         }
#
#
#
define oradb::listener( $oracleBase  = undef,
                        $oracleHome  = undef,
                        $user        = 'oracle',
                        $group       = 'dba',
                        $action      = 'start',
)

{
  $execPath = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${oracleHome}/bin"

  if $action == 'start' {
    exec { "listener start ${title}":
      command     => "${oracleHome}/bin/lsnrctl ${action}",
      path        => $execPath,
      user        => $user,
      group       => $group,
      environment => ["ORACLE_HOME=${oracleHome}", "ORACLE_BASE=${oracleBase}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput   => true,
      unless      => "/bin/ps -ef | grep -v grep | /bin/grep '${$oracleHome}/bin/tnslsnr'",
    }
  } else {
    exec { "listener other ${title}":
      command     => "${oracleHome}/bin/lsnrctl ${action}",
      path        => $execPath,
      user        => $user,
      group       => $group,
      environment => ["ORACLE_HOME=${oracleHome}", "ORACLE_BASE=${oracleBase}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput   => true,
      onlyif      => "/bin/ps -ef | grep -v grep | /bin/grep '${$oracleHome}/bin/tnslsnr'",
    }
  }
}