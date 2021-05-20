#
# goldengate
#
# install goldengate version 19.1, 18.1, 12.3.0, 12.2.1, 12.1.2 or 11.2
#
# @example goldengate install
#
#  oradb::goldengate{ 'ggate19.1':
#    version                    => '19.1',
#    file                       => '191004_fbo_ggs_Linux_x64_shiphome.zip',
#    database_type              => 'Oracle',
#    database_version           => 'ORA19c',
#    database_home              => '/oracle/product/19.3/db',
#    oracle_base                => '/oracle',
#    goldengate_home            => '/oracle/product/19.3/ggate',
#    manager_port               => 7809,
#    user                       => 'oracle',
#    group                      => 'dba',
#    group_install              => 'oinstall',
#    download_dir               => '/var/tmp/install',
#    puppet_download_mnt_point  => '/software',
#  }
#
#  oradb::goldengate{ 'ggate12.1.2':
#    version                    => '12.1.2',
#    file                       => '121210_fbo_ggs_Linux_x64_shiphome.zip',
#    database_type              => 'Oracle',
#    database_version           => 'ORA12c',
#    database_home              => '/oracle/product/12.1/db',
#    oracle_base                => '/oracle',
#    goldengate_home            => '/oracle/product/12.1/ggate',
#    manager_port               => 16000,
#    user                       => 'oracle',
#    group                      => 'dba',
#    group_install              => 'oinstall',
#    download_dir               => '/var/tmp/install',
#    puppet_download_mnt_point  => '/software',
#  }
#
#  oradb::goldengate{ 'ggate11.2.1':
#    version                    => '11.2.1',
#    file                       => 'ogg112101_fbo_ggs_Linux_x64_ora11g_64bit.zip',
#    tar_file                   => 'fbo_ggs_Linux_x64_ora11g_64bit.tar',
#    goldengate_home            => "/oracle/product/11.2.1/ggate",
#    user                       => 'oracle',
#    group                      => 'dba',
#    download_dir               => '/var/tmp/install',
#    puppet_download_mnt_point  => '/software',
#
# @param version goldengate software version
# @param file goldengate installation file
# @param tar_file tar file inside zip for 11g version
# @param database_type goldengate db version only for 12c
# @param database_version for oracle database 11g or 12c only for 12c
# @param oracle_base oracle base directory only for 12c
# @param ora_inventory_dir full path to the oracle inventory directory only for 12c
# @param database_version for oracle database 11g or 12c only for 12c
# @param oracle_base oracle base directory only for 12c
# @param ora_inventory_dir full path to the oracle inventory directory only for 12c
# @param manager_port manager port number
# @param goldengate_home full path to the goldengate home under oracle base
# @param user operating system username
# @param group operating system group name
# @param group_install operating system group install name
# @param puppet_download_mnt_point the location where the installation software is available
# @param download_dir location for installation files used by this module
# @param database_home the oracle database home for connecting goldengat only for 12c
#
define oradb::goldengate(
  String $version                                                = '12.2.1',
  String $file                                                   = undef,
  Optional[String] $tar_file                                     = undef,     # only for < 12.1.2
  Enum['Oracle'] $database_type                                  = 'Oracle',  # only for > 12.1.2
  Enum['ORA11g', 'ORA12c', 'ORA18c', 'ORA19c'] $database_version = 'ORA11g',  # only for > 12.1.2
  Optional[String] $database_home                                = undef,     # only for > 12.1.2
  Optional[String] $oracle_base                                  = undef,     # only for > 12.1.2
  Optional[String] $ora_inventory_dir                            = undef,     # only for > 12.1.2
  String $goldengate_home                                        = undef,
  Optional[Integer] $manager_port                                = undef,
  String $user                                                   = 'ggate',
  String $group                                                  = lookup('oradb::group'),
  String $group_install                                          = lookup('oradb::group_install'),
  String $download_dir                                           = lookup('oradb::download_dir'),
  String $puppet_download_mnt_point                              = lookup('oradb::module_mountpoint'),
)
{
  $exec_path = lookup('oradb::exec_path')

  if ( $version in ['12.1.2', '12.2.1', '12.3.0', '18.1', '19.1'] ) {
    # check if the oracle software already exists
    if ( $database_home == undef or is_string($database_home) == false) {fail('You must specify a database_home') }
    if ( $oracle_base == undef or is_string($oracle_base) == false) {fail('You must specify an oracle_base') }
    if ( $manager_port == undef or is_integer($manager_port) == false) {fail('You must specify a manager_port') }

    $found = oradb::oracle_exists( $goldengate_home )

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

  if ( $version in ['12.1.2', '12.2.1', '12.3.0', '18.1', '19.1'] ) {
    if $ora_inventory_dir == undef {
      $ora_inventory = oradb::cleanpath("${oracle_base}/../oraInventory")
    } else {
      validate_absolute_path($ora_inventory_dir)
      $ora_inventory = "${ora_inventory_dir}/oraInventory"
    }

    db_directory_structure{"oracle goldengate structure ${version}":
      ensure            => present,
      oracle_base_dir   => $oracle_base,
      ora_inventory_dir => $ora_inventory,
      download_dir      => $download_dir,
      os_user           => $user,
      os_group          => $group_install,
    }
  }

  # only for 12.1.2, 12.2.1, 12.3.0, 18.1, 19.1
  if ( $continue == true ) {

    $ggate_install_dir = 'fbo_ggs_Linux_x64_shiphome'

    file { "${download_dir}/${file}":
      source  => "${puppet_download_mnt_point}/${file}",
      owner   => $user,
      group   => $group,
      require => Db_directory_structure["oracle goldengate structure ${version}"],
    }

    exec { 'extract gg':
      command   => "unzip -o ${download_dir}/${file} -d ${download_dir}",
      creates   => "${download_dir}/${ggate_install_dir}",
      timeout   => 0,
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => false,
      require   => File["${download_dir}/${file}"],
    }

    file { "${download_dir}/oggcore.rsp":
      content => epp("oradb/oggcore_${version}.rsp.epp", {
                      'database_version' => $database_version,
                      'goldengate_home'  => $goldengate_home,
                      'database_home'    => $database_home,
                      'ora_inventory'    => $ora_inventory,
                      'group_install'    => $group_install,
                      'manager_port'     => $manager_port }),
      owner   => $user,
      group   => $group,
      require => Db_directory_structure["oracle goldengate structure ${version}"],
    }

    oradb::utils::dborainst{"ggate orainst ${version}":
      ora_inventory_dir => $ora_inventory,
      os_group          => $group_install,
    }

    exec { 'install oracle goldengate':
      command   => "/bin/sh -c 'unset DISPLAY;${download_dir}/${ggate_install_dir}/Disk1/runInstaller -silent -waitforcompletion -responseFile ${download_dir}/oggcore.rsp'",
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

  if ( $version != '12.1.2' and $version != '12.2.1' and $version != '12.3.0' and $version != '18.1' and $version != '19.1'){

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
