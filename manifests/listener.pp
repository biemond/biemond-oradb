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

  case $::kernel {
    'Linux': {
      $ps_bin = '/bin/ps'
      $ps_arg = '-ef'
    }
    'SunOS': {
      $ps_arg = 'awwx'
      if $::kernelrelease == '5.11' {
        $ps_bin = '/bin/ps'
      } else {
        $ps_bin = '/usr/ucb/ps'
      }
    }
    default: {
      fail('Unrecognized operating system')
    }
  }

  $command  = "${ps_bin} ${ps_arg} | /bin/grep -v grep | /bin/grep '${$oracleHome}/bin/tnslsnr'"


  if $action == 'start' {
    exec { "listener start ${title}":
      command     => "${oracleHome}/bin/lsnrctl ${action}",
      path        => $execPath,
      user        => $user,
      group       => $group,
      environment => ["ORACLE_HOME=${oracleHome}", "ORACLE_BASE=${oracleBase}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput   => true,
      unless      => $command,
    }
  } else {
    exec { "listener other ${title}":
      command     => "${oracleHome}/bin/lsnrctl ${action}",
      path        => $execPath,
      user        => $user,
      group       => $group,
      environment => ["ORACLE_HOME=${oracleHome}", "ORACLE_BASE=${oracleBase}", "LD_LIBRARY_PATH=${oracleHome}/lib"],
      logoutput   => true,
      onlyif      => $command,
    }
  }
}