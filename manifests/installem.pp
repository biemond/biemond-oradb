#
# installem
#
# install enterprise manager
#
# @example install EM
#
#  oradb::installem{ 'em12104':
#      version                     => '12.1.0.4',
#      file                        => 'em12104_linux64',
#      oracle_base_dir             => '/oracle',
#      oracle_home_dir             => '/oracle/product/12.1/em',
#      agent_base_dir              => '/oracle/product/12.1/agent',
#      software_library_dir        => '/oracle/product/12.1/swlib',
#      weblogic_user               => 'weblogic',
#      weblogic_password           => 'Welcome01',
#      database_hostname           => 'emdb.example.com',
#      database_listener_port      => 1521,
#      database_service_sid_name   => 'emrepos.example.com',
#      database_sys_password       => 'Welcome01',
#      sysman_password             => 'Welcome01',
#      agent_registration_password => 'Welcome01',
#      deployment_size             => 'SMALL',
#      user                        => 'oracle',
#      group                       => 'oinstall',
#      download_dir                => '/install',
#      zip_extract                 => true,
#      puppet_download_mnt_point   => '/software',
#      remote_file                 => false,
#      log_output                  => true,
#  }
#
# @param version Oracle installation version
# @param file filename of the installation software
# @param oracle_base_dir full path to the Oracle Base directory
# @param oracle_home_dir full path to the Oracle Home directory inside Oracle Base
# @param ora_inventory_dir full path to the Oracle Inventory location directory
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param download_dir location for installation files used by this module
# @param puppet_download_mnt_point the location where the installation software is available
# @param remote_file the installation is remote accessiable or not
# @param log_output log all output
# @param agent_base_dir
# @param software_library_dir
# @param weblogic_user
# @param weblogic_password
# @param database_hostname
# @param database_listener_port
# @param database_service_sid_name
# @param database_sys_password
# @param sysman_password
# @param agent_registration_password
# @param deployment_size
# @param zip_extract
# @param admin_server_https_port
# @param managed_server_http_port
# @param managed_server_https_port
# @param em_upload_http_port
# @param em_upload_https_port
# @param em_central_console_http_port
# @param em_central_console_https_port
# @param bi_publisher_http_port
# @param bi_publisher_https_port
# @param nodemanager_https_port
# @param agent_port
#
define oradb::installem(
  Enum['12.1.0.4','12.1.0.5'] $version              = '12.1.0.5',
  String $file                                      = undef,
  Optional[String] $ora_inventory_dir               = undef,
  String $oracle_base_dir                           = undef,
  String $oracle_home_dir                           = undef,
  Optional[String] $agent_base_dir                  = undef,
  Optional[String] $software_library_dir            = undef,
  String $weblogic_user                             = 'weblogic',
  Optional[String] $weblogic_password               = undef,
  String $database_hostname                         = undef,
  Integer $database_listener_port                   = 1521,
  String $database_service_sid_name                 = undef,
  String $database_sys_password                     = undef,
  String $sysman_password                           = undef,
  Optional[String] $agent_registration_password     = undef,
  Enum['SMALL', 'MEDIUM', 'LARGE'] $deployment_size = 'SMALL',
  String $user                                      = lookup('oradb::user'),
  String $group                                     = lookup('oradb::group_install'),
  String $download_dir                              = lookup('oradb::download_dir'),
  Boolean $zip_extract                              = true,
  String $puppet_download_mnt_point                 = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                              = true,
  Boolean $log_output                               = false,
  Integer $admin_server_https_port                  = 7101,
  Integer $managed_server_http_port                 = 7201,
  Integer $managed_server_https_port                = 7301,
  Integer $em_upload_http_port                      = 4889,
  Integer $em_upload_https_port                     = 1159,
  Integer $em_central_console_http_port             = 7788,
  Integer $em_central_console_https_port            = 7799,
  Integer $bi_publisher_http_port                   = 9701,
  Integer $bi_publisher_https_port                  = 9801,
  Integer $nodemanager_https_port                   = 7401,
  Integer $agent_port                               = 3872,
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
  $found = oradb::oracle_exists( $oracle_home_dir )

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
    $ora_inventory = oradb::cleanpath("${oracle_base_dir}/../oraInventory")
  } else {
    validate_absolute_path($ora_inventory_dir)
    $ora_inventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"oracle em structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base_dir,
    ora_inventory_dir => $ora_inventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group,
  }

  if ( $continue ) {

    $exec_path = lookup('oradb::exec_path')

    if $puppet_download_mnt_point == undef {
      $mount_point     = 'puppet:///modules/oradb/'
    } else {
      $mount_point     = $puppet_download_mnt_point
    }

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['12.1.0.4', '12.1.0.5']) {
        $file1 = "${file}_disk1.zip"
        $file2 = "${file}_disk2.zip"
        $file3 = "${file}_disk3.zip"
      }

      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mount_point}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Db_directory_structure["oracle em structure ${version}"],
          before  => Exec["extract ${download_dir}/${file1}"],
        }
        # db file 2 installer zip
        file { "${download_dir}/${file2}":
          ensure  => present,
          source  => "${mount_point}/${file2}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => File["${download_dir}/${file1}"],
          before  => Exec["extract ${download_dir}/${file2}"]
        }
        # db file 3 installer zip
        file { "${download_dir}/${file3}":
          ensure  => present,
          source  => "${mount_point}/${file3}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => File["${download_dir}/${file2}"],
          before  => Exec["extract ${download_dir}/${file3}"]
        }

        $source = $download_dir
      } else {
        $source = $mount_point
      }

      exec { "extract ${download_dir}/${file1}":
        command   => "unzip -o ${source}/${file1} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        require   => Db_directory_structure["oracle em structure ${version}"],
        before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file2}":
        command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file1}"],
        before    => Exec["install oracle em ${title}"],
      }
      exec { "extract ${download_dir}/${file3}":
        command   => "unzip -o ${source}/${file3} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file2}"],
        before    => Exec["install oracle em ${title}"],
      }

    }

    oradb::utils::dborainst{"em orainst ${version}":
      ora_inventory_dir => $ora_inventory,
      os_group          => $group,
    }

    if ! defined(File["${download_dir}/em_install_${version}.rsp"]) {
      file { "${download_dir}/em_install_${version}.rsp":
        ensure  => present,
        content => epp("oradb/em_install_${version}.rsp.epp",
                      { 'group_install'               => $group,
                        'oraInventory'                => $ora_inventory,
                        'agent_base_dir'              => $agent_base_dir,
                        'oracle_home_dir'             => $oracle_home_dir,
                        'weblogic_user'               => $weblogic_user,
                        'weblogic_password'           => $weblogic_password,
                        'database_hostname'           => $database_hostname,
                        'database_listener_port'      => $database_listener_port,
                        'database_service_sid_name'   => $database_service_sid_name,
                        'database_sys_password'       => $database_sys_password,
                        'sysman_password'             => $sysman_password,
                        'software_library_dir'        => $software_library_dir,
                        'deployment_size'             => $deployment_size,
                        'agent_registration_password' => $agent_registration_password,
                        'download_dir'                => $download_dir,
                        'version'                     => $version }),
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
        content => epp("oradb/em_install_static_${version}.ini.epp",
                      { 'admin_server_https_port'       => $admin_server_https_port,
                        'managed_server_http_port'      => $managed_server_http_port,
                        'managed_server_https_port'     => $managed_server_https_port,
                        'em_upload_http_port'           => $em_upload_http_port,
                        'em_upload_https_port'          => $em_upload_https_port,
                        'em_central_console_http_port'  => $em_central_console_http_port,
                        'em_central_console_https_port' => $em_central_console_https_port,
                        'bi_publisher_http_port'        => $bi_publisher_http_port,
                        'bi_publisher_https_port'       => $bi_publisher_https_port,
                        'nodemanager_https_port'        => $nodemanager_https_port,
                        'agent_port'                    => $agent_port } ),
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
      path      => $exec_path,
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
      path      => $exec_path,
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
        path    => $exec_path,
        require => [Exec["install oracle em ${title}"],
                    Exec["run root.sh script ${title}"],],
      }

      if ( $remote_file == true ){
        exec { "remove oracle em file1 ${file1} ${title}":
          command => "rm -rf ${download_dir}/${file1}",
          user    => 'root',
          group   => 'root',
          path    => $exec_path,
          require => Exec["install oracle em ${title}"],
        }
        exec { "remove oracle em file2 ${file2} ${title}":
          command => "rm -rf ${download_dir}/${file2}",
          user    => 'root',
          group   => 'root',
          path    => $exec_path,
          require => Exec["install oracle em ${title}"],
        }
        exec { "remove oracle em file3 ${file3} ${title}":
          command => "rm -rf ${download_dir}/${file3}",
          user    => 'root',
          group   => 'root',
          path    => $exec_path,
          require => Exec["install oracle em ${title}"],
        }

      }
    }

  }
}
