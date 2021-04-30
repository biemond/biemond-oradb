# client
#
# installs oracle client
#
# @example example installation of oracle client
#    oradb::client{ '12.1.0.1_Linux-x86-64':
#      version                   => '12.1.0.1',
#      file                      => 'linuxamd64_12c_client.zip',
#      oracle_base               => '/oracle',
#      oracle_home               => '/oracle/product/12.1/client',
#      user                      => 'oracle',
#      group                     => 'dba',
#      group_install             => 'oinstall',
#      download_dir              => '/install',
#      bash_profile              => true,
#      remote_file               => true,
#      puppet_download_mnt_point => "puppet:///modules/oradb/",
#      log_output                => true,
#    }
#
#    oradb::client{ '11.2.0.1_Linux-x86-64':
#      version                   => '11.2.0.1',
#      file                      => 'linux.x64_11gR2_client.zip',
#      oracle_base               => '/oracle',
#      oracle_home               => '/oracle/product/11.2/client',
#      user                      => 'oracle',
#      group                     => 'dba',
#      group_install             => 'oinstall',
#      download_dir              => '/install',
#      bash_profile              => true,
#      remote_file               => false,
#      puppet_download_mnt_point => "/software",
#      log_output                => true,
#    }
#
# @param version Oracle installation version
# @param file filename of the installation software
# @param oracle_base full path to the Oracle Base directory
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param ora_inventory_dir full path to the Oracle Inventory location directory
# @param db_port database listener port number
# @param user operating system user
# @param user_base_dir the location of the base user homes
# @param group the operating group name for using the oracle software
# @param group_install the operating group name for the installed software
# @param download_dir location for installation files used by this module
# @param bash_profile add a bash profile to the operating user
# @param puppet_download_mnt_point the location where the installation software is available
# @param remote_file the installation is remote accessiable or not
# @param log_output log all output
# @param temp_dir location for temporaray file used by the installer
# @param image_install unzip client_home.zip and use runInstaller
#
define oradb::client(
  Enum['11.2.0.1','11.2.0.4','12.1.0.1','12.1.0.2','12.2.0.1','18.0.0.0','19.0.0.0'] $version = undef,
  String $file                                                          = undef,
  Stdlib::Absolutepath $oracle_base                                     = undef,
  Stdlib::Absolutepath $oracle_home                                     = undef,
  Optional[String] $ora_inventory_dir                                   = undef,
  Integer $db_port                                                      = lookup('oradb::listener_port'),
  String $user                                                          = lookup('oradb::user'),
  String $user_base_dir                                                 = lookup('oradb::user_base_dir'),
  String $group                                                         = lookup('oradb::group'),
  String $group_install                                                 = lookup('oradb::group_install'),
  String $download_dir                                                  = lookup('oradb::download_dir'),
  Boolean $bash_profile                                                 = true,
  String $puppet_download_mnt_point                                     = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                                                  = true,
  Boolean $log_output                                                   = true,
  String $temp_dir                                                      = lookup('oradb::tmp_dir'),
  Enum['client','client32'] $install_type                               = 'client',
  Boolean $image_install                                                = false,
)
{
  # check if the oracle software already exists
  $found = oradb::oracle_exists( $oracle_home )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installdb ${oracle_home} does not exists":}
      $continue = true
    }
  }

  if $ora_inventory_dir == undef {
    $ora_inventory = oradb::cleanpath("${oracle_base}/../oraInventory")
  } else {
    validate_absolute_path($ora_inventory_dir)
    $ora_inventory = "${ora_inventory_dir}/oraInventory"
  }
  
  if ( $image_install ) {
    # add oracle home for the unzip
    db_directory_structure{"client structure ${title}":
      ensure            => present,
      oracle_base_dir   => $oracle_base,
      oracle_home_dir   => $oracle_home,
      ora_inventory_dir => $ora_inventory,
      download_dir      => $download_dir,
      os_user           => $user,
      os_group          => $group_install,
    }
  } else {
    db_directory_structure{"client structure ${title}":
      ensure            => present,
      oracle_base_dir   => $oracle_base,
      ora_inventory_dir => $ora_inventory,
      download_dir      => $download_dir,
      os_user           => $user,
      os_group          => $group_install,
    }
  }

  if ( $image_install ) and !( $version in ['18.0.0.0', '19.0.0.0'] ) {
    fail('Image Install not supported on this oracle client version!')
  }

  if ( $continue ) {

    $exec_path = lookup('oradb::exec_path')

    # db file installer zip
    if $remote_file == true {
      file { "${download_dir}/${file}":
        ensure  => present,
        source  => "${puppet_download_mnt_point}/${file}",
        before  => Exec["extract ${download_dir}/${file}"],
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Db_directory_structure["client structure ${title}"],
      }
      $source = $download_dir
    } else {
      $source = $puppet_download_mnt_point
    }

  if ( $image_install ) {
      exec { "extract ${download_dir}/${file}":
        command   => "unzip -o ${source}/${file} -d ${oracle_home}",
        timeout   => 0,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        logoutput => false,
        require   => Db_directory_structure["client structure ${title}"],
      }
  } else {
      exec { "extract ${download_dir}/${file}":
        command   => "unzip -o ${source}/${file} -d ${download_dir}/client_${version}",
        timeout   => 0,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        logoutput => false,
        require   => Db_directory_structure["client structure ${title}"],
      }
  }

    oradb::utils::dborainst{"oracle orainst ${title}":
      ora_inventory_dir => $ora_inventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/db_${install_type}_${version}.rsp"]) {
      file { "${download_dir}/db_${install_type}_${version}.rsp":
        ensure  => present,
        content => epp("oradb/db_client_${version}.rsp.epp", {
                        'group_install' => $group_install,
                        'oraInventory'  => $ora_inventory,
                        'oracle_home'   => $oracle_home,
                        'oracle_base'   => $oracle_base }),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["oracle orainst ${title}"],
                    Db_directory_structure["client structure ${title}"],],
      }
    }
    if ($image_install) {
      $command = "/bin/sh -c 'unset DISPLAY;cd ${oracle_home};./runInstaller -silent -waitforcompletion -force -responseFile ${download_dir}/db_${install_type}_${version}.rsp'"

    } else {
      $command = "/bin/sh -c 'unset DISPLAY;${download_dir}/client_${version}/${install_type}/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/db_${install_type}_${version}.rsp'"
    }
    # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
    exec { "install oracle client ${title}":
      command     => $command,
      require     => [Oradb::Utils::Dborainst["oracle orainst ${title}"],
                      File["${download_dir}/db_${install_type}_${version}.rsp"],
                      Exec["extract ${download_dir}/${file}"]],
      #creates     => $oracle_home, # remove creates to support image install.
      timeout     => 0,
      returns     => [6,0],
      path        => $exec_path,
      user        => $user,
      group       => $group_install,
      logoutput   => $log_output,
      environment => "TEMP=${temp_dir}",
    }

    exec { "run root.sh script ${title}":
      command   => "${oracle_home}/root.sh",
      user      => 'root',
      group     => 'root',
      require   => Exec["install oracle client ${title}"],
      path      => $exec_path,
      logoutput => $log_output,
    }

    file { "${download_dir}/netca_${install_type}_${version}.rsp":
      ensure  => present,
      content => epp("oradb/netca_client_${version}.rsp.epp", { 'db_port' => $db_port }),
      require => Exec["run root.sh script ${title}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }

    exec { "install oracle net ${title}":
      command   => "${oracle_home}/bin/netca /silent /responsefile ${download_dir}/netca_${install_type}_${version}.rsp",
      require   => [File["${download_dir}/netca_${install_type}_${version}.rsp"],Exec["run root.sh script ${title}"],],
      creates   => "${oracle_home}/network/admin/sqlnet.ora",
      path      => $exec_path,
      user      => $user,
      group     => $group,
      logoutput => $log_output,
    }

    if ( $bash_profile == true ) {
      if ! defined(File["${user_base_dir}/${user}/.bash_profile"]) {
        file { "${user_base_dir}/${user}/.bash_profile":
          ensure  => present,
          # content => template('oradb/bash_profile.erb'),
          content => regsubst(epp('oradb/bash_profile.epp', { 'oracle_home' => $oracle_home,
                                                              'oracle_base' => $oracle_base,
                                                              'temp_dir'    => $temp_dir }), '\r\n', "\n", 'EMG'),
          mode    => '0775',
          owner   => $user,
          group   => $group,
        }
      }
    }

    # cleanup
    exec { "remove oracle client extract folder ${title}":
      command => "rm -rf ${download_dir}/client_${version}",
      user    => 'root',
      group   => 'root',
      path    => $exec_path,
      require => Exec["install oracle net ${title}"],
    }

    if ( $remote_file == true ){
      exec { "remove oracle client file ${file} ${title}":
        command => "rm -rf ${download_dir}/${file}",
        user    => 'root',
        group   => 'root',
        path    => $exec_path,
        before  => Exec["install oracle client ${title}"],
        require => Exec["extract ${download_dir}/${file}"],
      }
    }

  }
}
