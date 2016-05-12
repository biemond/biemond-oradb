#
#
#
define oradb::goldengate(
  String $version            = '12.1.2',
  $file                      = undef,
  $tar_file                  = undef,     # only for < 12.1.2
  String $database_type      = 'Oracle',  # only for > 12.1.2
  Enum["ORA11g", "ORA12c"]$database_version = 'ORA11g', # ORA12c'  only for > 12.1.2
  $database_home             = undef,     # only for > 12.1.2
  $oracle_base               = undef,     # only for > 12.1.2
  $ora_inventory_dir         = undef,
  $goldengate_home           = undef,
  $manager_port              = undef,
  String $user                      = 'ggate',
  String $group                     = lookup('oradb::group'),
  String $group_install             = lookup('oradb::group_install'),
  String $download_dir              = lookup('oradb::download_dir'),
  String $puppet_download_mnt_point = lookup('oradb::module_mountpoint'),
)
{
  if ( $goldengate_home == undef or is_string($goldengate_home) == false) {fail('You must specify a goldengate_home') }
  if ( $file == undef or is_string($file) == false) {fail('You must specify a file') }
  if ( $puppet_download_mnt_point == undef or is_string($puppet_download_mnt_point) == false) {fail('You must specify a puppet_download_mnt_point') }

  $exec_path = lookup('oradb::exec_path')

  if ( $version == '12.1.2' ) {
    # check if the oracle software already exists
    if (!( $database_type in ['Oracle'] )) {
      fail('Unrecognized database_type')
    }
    if (!( $database_version in ['ORA11g','ORA12c'] )) {
      fail('Unrecognized database_version')
    }
    if ( $database_home == undef or is_string($database_home) == false) {fail('You must specify a database_home') }
    if ( $oracle_base == undef or is_string($oracle_base) == false) {fail('You must specify an oracle_base') }
    if ( $manager_port == undef or is_integer($manager_port) == false) {fail('You must specify a manager_port') }

    $found = oracle_exists( $goldengate_home )

    if $found == undef {
      $continue = true
    } else {
      if ( $found ) {
        $continue = false
      } else {
        notify {"oradb::goldengate ${goldengate_home} does not exists":}
        $continue = true
      }
    }
  } else {
    $continue = false
  }


  if ( $version == '12.1.2' ) {
    if $ora_inventory_dir == undef {
      $oraInventory = pick($::oradb_inst_loc_data, oradb_cleanpath("${oracle_base}/../oraInventory"))
    } else {
      validate_absolute_path($ora_inventory_dir)
      $oraInventory = "${ora_inventory_dir}/oraInventory"
    }

    db_directory_structure{"oracle goldengate structure ${version}":
      ensure            => present,
      oracle_base_dir   => $oracle_base,
      ora_inventory_dir => $oraInventory,
      download_dir      => $download_dir,
      os_user           => $user,
      os_group          => $group_install,
    }
  }

  # only for 12.1.2
  if ( $continue == true ) {

    $ggateInstallDir = 'fbo_ggs_Linux_x64_shiphome'

    file { "${download_dir}/${file}":
      source  => "${puppet_download_mnt_point}/${file}",
      owner   => $user,
      group   => $group,
      require => Db_directory_structure["oracle goldengate structure ${version}"],
    }

    exec { 'extract gg':
      command   => "unzip -o ${download_dir}/${file} -d ${download_dir}",
      creates   => "${download_dir}/${ggateInstallDir}",
      timeout   => 0,
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => false,
      require   => File["${download_dir}/${file}"],
    }

    file { "${download_dir}/oggcore.rsp":
      content => template("oradb/oggcore_${version}.rsp.erb"),
      owner   => $user,
      group   => $group,
      require => Db_directory_structure["oracle goldengate structure ${version}"],
    }

    oradb::utils::dborainst{"ggate orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    exec { 'install oracle goldengate':
      command   => "/bin/sh -c 'unset DISPLAY;${download_dir}/${ggateInstallDir}/Disk1/runInstaller -silent -waitforcompletion -responseFile ${download_dir}/oggcore.rsp'",
      require   => [File["${download_dir}/oggcore.rsp"],
                    Oradb::Utils::Dborainst["ggate orainst ${version}"],
                    Exec['extract gg'],],
      creates   => $goldengate_home,
      timeout   => 0,
      path      => $exec_path,
      logoutput => true,
      user      => $user,
      group     => $group_install,
      returns   => [3,0],
    }

  }

  if ( $version != '12.1.2' ){

    if ( $tar_file == undef or is_string($tar_file) == false) {fail("${title} You must specify a tar_file") }

    # # check oracle install folder
    # if !defined(File[$download_dir]) {
    #   file { $download_dir:
    #     ensure  => directory,
    #     recurse => false,
    #     replace => false,
    #     mode    => '0777',
    #   }
    # }

    #version is different, use the old way
    file { "${download_dir}/${file}":
      source => "${puppet_download_mnt_point}/${file}",
      owner  => $user,
      group  => $group,
    }

    exec { "extract gg ${title}":
      command   => "unzip -o ${download_dir}/${file} -d ${download_dir}",
      require   => File["${download_dir}/${file}"],
      creates   => "${download_dir}/${tar_file}",
      timeout   => 0,
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => true,
    }

    file { $goldengate_home :
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }

    exec { "extract tar ${title}":
      command   => "tar -xf ${download_dir}/${tar_file} -C ${goldengate_home}",
      require   => [File[$goldengate_home],
                    Exec["extract gg ${title}"]],
      creates   => "${goldengate_home}/ggsci",
      timeout   => 0,
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => true,
    }
  }
}
