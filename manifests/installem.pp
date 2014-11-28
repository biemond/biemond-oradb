# == Class: oradb::installem
#s
#
define oradb::installem(
  $version                     = '12.1.0.4',
  $file                        = undef,
  $ora_inventory_dir           = undef,
  $oracle_base_dir             = undef,
  $oracle_home_dir             = undef,
  $agent_base_dir              = undef,
  $software_library_dir        = undef,
  $weblogic_user               = 'weblogic',
  $weblogic_password           = undef,
  $database_hostname           = undef,
  $database_listener_port      = 1521,
  $database_service_sid_name   = undef,
  $database_sys_password       = undef,
  $sysman_password             = undef,
  $agent_registration_password = undef,
  $deployment_size             = 'SMALL', #'SMALL','MEDIUM','LARGE'
  $user                        = 'oracle',
  $group                       = 'oinstall',
  $download_dir                = '/install',
  $zip_extract                 = true,
  $puppet_download_mnt_point   = undef,
  $remote_file                 = true,
  $log_output                  = false,
)
{

  if (!( $version in ['12.1.0.4'])){
    fail('Unrecognized em version, use 12.1.0.4')
  }

  if ( !($::kernel in ['Linux','SunOS'])){
    fail('Unrecognized operating system, please use it on a Linux or SunOS host')
  }

  # check if the oracle software already exists
  $found = oracle_exists( $oracle_home_dir )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installem ${oracle_home_dir} does not exists":}
      $continue = true
    }
  }

  if ( $continue ) {

    $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

    if $puppet_download_mnt_point == undef {
      $mountPoint     = 'puppet:///modules/oradb/'
    } else {
      $mountPoint     = $puppet_download_mnt_point
    }

    if $ora_inventory_dir == undef {
      $oraInventory = "${oracle_base_dir}/oraInventory"
    } else {
      $oraInventory = "${ora_inventory_dir}/oraInventory"
    }

    oradb::utils::dbstructure{"oracle structure ${version}":
      oracle_base_home_dir => $oracle_base_dir,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      os_group_install     => undef,
      os_group_oper        => undef,
      download_dir         => $download_dir,
      log_output           => $log_output,
      user_base_dir        => undef,
      create_user          => false,
    }


    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['12.1.0.4']) {
        $file1 =  "${file}_disk1.zip"
        $file2 =  "${file}_disk2.zip"
        $file3 =  "${file}_disk3.zip"
      }


      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mountPoint}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Oradb::Utils::Dbstructure["oracle structure ${version}"],
          before  => Exec["extract ${download_dir}/${file1}"],
        }
        # db file 2 installer zip
        file { "${download_dir}/${file2}":
          ensure  => present,
          source  => "${mountPoint}/${file2}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => File["${download_dir}/${file1}"],
          before  => Exec["extract ${download_dir}/${file2}"]
        }
        # db file 3 installer zip
        file { "${download_dir}/${file3}":
          ensure  => present,
          source  => "${mountPoint}/${file3}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => File["${download_dir}/${file2}"],
          before  => Exec["extract ${download_dir}/${file3}"]
        }

        $source = $download_dir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${download_dir}/${file1}":
        command   => "unzip -o ${source}/${file1} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Oradb::Utils::Dbstructure["oracle structure ${version}"],
        # before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file2}":
        command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file1}"],
        # before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file3}":
        command   => "unzip -o ${source}/${file3} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file2}"],
        # before    => Exec["install oracle em ${title}"],
      }

    }

    oradb::utils::dborainst{"em orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group,
    }

    if ! defined(File["${download_dir}/em_install_${version}.rsp"]) {
      file { "${download_dir}/em_install_${version}.rsp":
        ensure  => present,
        content => template("oradb/em_install_${version}.rsp.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Dborainst["em orainst ${version}"],
      }
    }
    if ! defined(File["${download_dir}/em_install_static_${version}.ini"]) {
      file { "${download_dir}/em_install_static_${version}.ini":
        ensure  => present,
        content => template("oradb/em_install_static_${version}.ini.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Dborainst["em orainst ${version}"],
      }
    }

    if ( $version in ['12.1.0.4']){
      exec { "install oracle em ${title}":
        command   => "/bin/sh -c 'unset DISPLAY;${download_dir}/${file}/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/em_install_${version}.rsp'",
        creates   => $oracle_home_dir,
        timeout   => 0,
        returns   => [6,0],
        path      => $execPath,
        user      => $user,
        group     => $group,
        logoutput => true,
        require   => [Oradb::Utils::Dborainst["em orainst ${version}"],
                      File["${download_dir}/em_install_${version}.rsp"],
                      File["${download_dir}/em_install_static_${version}.ini"],],
      }

      file { $oracle_home_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Exec["install oracle em ${title}"],
      }
    }

    exec { "run root.sh script ${title}":
      command   => "${oracle_home_dir}/oms/allroot.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      logoutput => true,
      require   => Exec["install oracle em ${title}"],
    }
  }
}
