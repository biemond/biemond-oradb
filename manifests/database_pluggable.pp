#
# database_pluggable
#
# add or delete a pluggable database to a container database
#
# @example pluggable database
#
#    oradb::database_pluggable{'pdb1':
#      ensure                   => 'present',
#      version                  => '12.1',
#      oracle_home_dir          => '/oracle/product/12.1/db',
#      user                     => 'oracle',
#      group                    => 'dba',
#      source_db                => 'orcl',
#      pdb_name                 => 'pdb1',
#      pdb_admin_username       => 'pdb_adm',
#      pdb_admin_password       => 'Welcome01',
#      pdb_datafile_destination => "/oracle/oradata/orcl/pdb1",
#      create_user_tablespace   => true,
#      log_output               => true,
#    }
# 
# @param version Oracle installation version
# @param oracle_home_dir full path to the Oracle Home directory inside Oracle Base
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param log_output log all output
# @param ensure add or delete the pluggable container
# @param source_db the source container database
# @param pdb_name the pluggable DB name
# @param pdb_datafile_destination the pluggable DB datafile location
# @param pdb_admin_username the pluggable DB admin username
# @param pdb_admin_password the pluggable DB admin password
# @param create_user_tablespace create user tablespace for the pluggable DB
#
define oradb::database_pluggable(
  Enum['present', 'absent'] $ensure = 'present',
  Enum['12.1', '12.2'] $version     = lookup('oradb::version'),
  String $oracle_home_dir           = undef,
  String $user                      = lookup('oradb::user'),
  String $group                     = lookup('oradb::group'),
  String $source_db                 = undef,
  String $pdb_name                  = undef,
  String $pdb_datafile_destination  = undef,
  String $pdb_admin_username        = 'pdb_adm',
  String $pdb_admin_password        = undef,
  Boolean $create_user_tablespace   = true,
  Boolean $log_output               = false,
){
  $exec_path = lookup('oradb::exec_path')

  if ( $ensure == 'present') {
    $command = "${oracle_home_dir}/bin/dbca -silent -createPluggableDatabase -sourceDB ${source_db} -pdbName ${pdb_name} -createPDBFrom DEFAULT -pdbAdminUserName ${pdb_admin_username} -pdbAdminPassword ${pdb_admin_password} -pdbDatafileDestination ${pdb_datafile_destination} -createUserTableSpace ${create_user_tablespace}"

    exec { "dbca pdb execute ${title}":
      command   => $command,
      timeout   => 0,
      path      => $exec_path,
      cwd       => $oracle_home_dir,
      user      => $user,
      group     => $group,
      creates   => $pdb_datafile_destination,
      logoutput => $log_output,
    }
  } else {
    $command = "${oracle_home_dir}/bin/dbca -silent -deletePluggableDatabase -sourceDB ${source_db} -pdbName ${pdb_name}"

    exec { "dbca pdb execute ${title}":
      command   => $command,
      timeout   => 0,
      path      => $exec_path,
      cwd       => $oracle_home_dir,
      user      => $user,
      group     => $group,
      onlyif    => "ls ${$pdb_datafile_destination}",
      logoutput => $log_output,
    }

  }
}