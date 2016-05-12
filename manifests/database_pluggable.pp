#
#
define oradb::database_pluggable(
  Enum["present", "absent"] $ensure = 'present',
  String $version                  = lookup('oradb::version'),
  String $oracle_home_dir          = undef,
  String $user                     = lookup('oradb::user'),
  String $group                    = lookup('oradb::group'),
  String $source_db                = undef,
  String $pdb_name                 = undef,
  String $pdb_datafile_destination = undef,
  String $pdb_admin_username       = 'pdb_adm',
  String $pdb_admin_password       = undef,
  Boolean $create_user_tablespace  = true,
  Boolean $log_output              = false,
){

  if ( $version in lookup('oradb::database_pluggable_versions') == false ){
    fail('Unrecognized version, use 12.1')
  }

  if ( $source_db == undef or is_string($source_db) == false) {fail('You must specify an source_db') }
  if ( $pdb_name == undef or is_string($pdb_name) == false) {fail('You must specify an pdb_name') }
  if ( $pdb_datafile_destination == undef or is_string($pdb_datafile_destination) == false) {fail('You must specify an pdb_datafile_destination') }

  if ( $ensure == 'present') {
    if ( $pdb_admin_username == undef or is_string($pdb_admin_username) == false) {fail('You must specify an pdb_admin_username') }
    if ( $pdb_admin_password == undef or is_string($pdb_admin_password) == false) {fail('You must specify an pdb_admin_password') }
  }

  $execPath = lookup('oradb::exec_path')

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