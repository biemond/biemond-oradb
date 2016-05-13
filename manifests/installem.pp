# == Class: oradb::installem
#s
#
define oradb::installem(
  String $version                       = '12.1.0.5',
  String $file                          = undef,
  $ora_inventory_dir                    = undef,
  String $oracle_base_dir               = undef,
  String $oracle_home_dir               = undef,
  $agent_base_dir                       = undef,
  $software_library_dir                 = undef,
  String $weblogic_user                 = 'weblogic',
  $weblogic_password                    = undef,
  String $database_hostname             = undef,
  Integer $database_listener_port       = 1521,
  String $database_service_sid_name     = undef,
  String $database_sys_password         = undef,
  String $sysman_password               = undef,
  $agent_registration_password          = undef,
  Enum["SMALL", "MEDIUM", "LARGE"] $deployment_size = 'SMALL',
  String $user                           = lookup('oradb::user'),
  String $group                          = lookup('oradb::group_install'),
  String $download_dir                   = lookup('oradb::download_dir'),
  Boolean $zip_extract                   = true,
  String $puppet_download_mnt_point      = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                   = true,
  Boolean $log_output                    = false,
  Integer $admin_server_https_port       = 7101,
  Integer $managed_server_http_port      = 7201,
  Integer $managed_server_https_port     = 7301,
  Integer $em_upload_http_port           = 4889,
  Integer $em_upload_https_port          = 1159,
  Integer $em_central_console_http_port  = 7788,
  Integer $em_central_console_https_port = 7799,
  Integer $bi_publisher_http_port        = 9701,
  Integer $bi_publisher_https_port       = 9801,
  Integer $nodemanager_https_port        = 7401,
  Integer $agent_port                    = 3872,
)
{

  $supported_em_versions = join( lookup('oradb::enterprise_manager_versions'), '|')
  if ( $version in $supported_em_versions == false ){
    fail("Unrecognized em version, use ${supported_em_versions}")
  }

  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $::kernel in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
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

  if $ora_inventory_dir == undef {
    $oraInventory = pick($::oradb_inst_loc_data, oradb_cleanpath("${oracle_base_dir}/../oraInventory"))
  } else {
    validate_absolute_path($ora_inventory_dir)
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"oracle em structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base_dir,
    ora_inventory_dir => $oraInventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group,
  }

  if ( $continue ) {

    $execPath = lookup('oradb::exec_path')

    if $puppet_download_mnt_point == undef {
      $mountPoint     = 'puppet:///modules/oradb/'
    } else {
      $mountPoint     = $puppet_download_mnt_point
    }

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['12.1.0.4', '12.1.0.5']) {
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
          require => Db_directory_structure["oracle em structure ${version}"],
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
        require   => Db_directory_structure["oracle em structure ${version}"],
        before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file2}":
        command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file1}"],
        before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file3}":
        command   => "unzip -o ${source}/${file3} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file2}"],
        before    => Exec["install oracle em ${title}"],
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
        require => [Oradb::Utils::Dborainst["em orainst ${version}"],
                    Db_directory_structure["oracle em structure ${version}"],],
      }
    }
    if ! defined(File["${download_dir}/em_install_static_${version}.ini"]) {
      file { "${download_dir}/em_install_static_${version}.ini":
        ensure  => present,
        content => template("oradb/em_install_static_${version}.ini.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["em orainst ${version}"],
                    Db_directory_structure["oracle em structure ${version}"],],
      }
    }

    exec { "install oracle em ${title}":
      command   => "/bin/su - ${user} -c 'unset DISPLAY;${download_dir}/${file}/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/em_install_${version}.rsp'",
      creates   => $oracle_home_dir,
      timeout   => 0,
      returns   => [6,0],
      path      => $execPath,
      cwd       => $oracle_base_dir,
      logoutput => true,
      require   => [Oradb::Utils::Dborainst["em orainst ${version}"],
                    File["${download_dir}/em_install_${version}.rsp"],
                    File["${download_dir}/em_install_static_${version}.ini"],],
    }

    exec { "run root.sh script ${title}":
      command   => "${oracle_home_dir}/oms/allroot.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      cwd       => $oracle_base_dir,
      logoutput => $log_output,
      require   => Exec["install oracle em ${title}"],
    }

    file { $oracle_home_dir:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
      require => Exec["install oracle em ${title}","run root.sh script ${title}"],
    }

    # cleanup
    if ( $zip_extract ) {
      exec { "remove oracle em extract folder ${title}":
        command => "rm -rf ${download_dir}/${file}",
        user    => 'root',
        group   => 'root',
        path    => $execPath,
        require => [Exec["install oracle em ${title}"],
                    Exec["run root.sh script ${title}"],],
      }

      if ( $remote_file == true ){
        exec { "remove oracle em file1 ${file1} ${title}":
          command => "rm -rf ${download_dir}/${file1}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          require => Exec["install oracle em ${title}"],
        }
        exec { "remove oracle em file2 ${file2} ${title}":
          command => "rm -rf ${download_dir}/${file2}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          require => Exec["install oracle em ${title}"],
        }
        exec { "remove oracle em file3 ${file3} ${title}":
          command => "rm -rf ${download_dir}/${file3}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          require => Exec["install oracle em ${title}"],
        }

      }
    }

  }
}
