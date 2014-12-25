#
#
define oradb::database_pluggable(
  $ensure                   = 'present',  #present|absent
  $version                  = '12.1',
  $oracle_home_dir          = undef,
  $user                     = 'oracle',
  $group                    = 'dba',
  $source_db                = undef,
  $pdb_name                 = undef,
  $pdb_datafile_destination = undef,
  $pdb_admin_username       = 'pdb_adm',
  $pdb_admin_password       = undef,
  $create_user_tablespace   = true,
  $log_output               = false,
){

  if (!( $version == '12.1')){
    fail('Unrecognized version, use 12.1')
  }

  if (!( $ensure in ['present','absent'])){
    fail('Unrecognized ensure value, use present or absent')
  }

  if ( $source_db == undef or is_string($source_db) == false) {fail('You must specify an source_db') }
  if ( $pdb_name == undef or is_string($pdb_name) == false) {fail('You must specify an pdb_name') }
  if ( $pdb_datafile_destination == undef or is_string($pdb_datafile_destination) == false) {fail('You must specify an pdb_datafile_destination') }

  if ( $ensure == 'present') {
    if ( $pdb_admin_username == undef or is_string($pdb_admin_username) == false) {fail('You must specify an pdb_admin_username') }
    if ( $pdb_admin_password == undef or is_string($pdb_admin_password) == false) {fail('You must specify an pdb_admin_password') }
  }

  $execPath = "${oracle_home_dir}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

  if ( $ensure == 'present') {
    $command = "${oracle_home_dir}/bin/dbca -silent -createPluggableDatabase -sourceDB ${source_db} -pdbName ${pdb_name} -createPDBFrom DEFAULT -pdbAdminUserName ${pdb_admin_username} -pdbAdminPassword ${pdb_admin_password} -pdbDatafileDestination ${pdb_datafile_destination} -createUserTableSpace ${create_user_tablespace}"

    exec { "dbca pdb execute ${title}":
      command   => $command,
      timeout   => 0,
      path      => $execPath,
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
      path      => $execPath,
      cwd       => $oracle_home_dir,
      user      => $user,
      group     => $group,
      onlyif    => "ls ${$pdb_datafile_destination}",
      logoutput => $log_output,
    }

  }
}