#
# installdb
#
# install Oracle Database
#
# @example install Oracle database
#
#  oradb::installdb{ 'db_linux-x64':
#      version                => '11.2.0.4',
#      file                   => 'p13390677_112040_Linux-x86-64',
#      database_type          => 'EE',
#      ora_inventory_dir      => '/app',
#      oracle_base            => '/app/oracle',
#      oracle_home            => '/app/oracle/product/11.2/db',
#      user_base_dir          => '/home',
#      user                   => 'oracle',
#      group                  => 'dba',
#      group_install          => 'oinstall',
#      group_oper             => 'oper',
#      download_dir           => '/var/tmp/install',
#      remote_file            => false,
#      puppet_download_mnt_point => '/software',
#  }
#    
# @param version Oracle installation version
# @param file filename of the installation software
# @param oracle_base full path to the Oracle Base directory
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param ora_inventory_dir full path to the Oracle Inventory location directory
# @param user operating system user
# @param user_base_dir the location of the base user homes
# @param group the operating group name for using the oracle software
# @param group_install the operating group name for the installed software
# @param download_dir location for installation files used by this module
# @param bash_profile add a bash profile to the operating user
# @param puppet_download_mnt_point the location where the installation software is available
# @param remote_file the installation is remote accessiable or not
# @param temp_dir location for temporaray file used by the installer
# @param database_type
# @param ee_options_selection
# @param ee_optional_components
# @param group_oper
# @param zip_extract
# @param cluster_nodes
# @param cleanup_install_files
# @param is_rack_one_install
# @param remote_node
#
define oradb::installdb(
  Enum['11.2.0.1','11.2.0.3','11.2.0.4','12.1.0.1','12.1.0.2','12.2.0.1'] $version = undef,
  String $file                                                                     = undef,
  Enum['SE', 'EE', 'SEONE'] $database_type                                         = lookup('oradb:installdb:database_type'),
  Optional[String] $ora_inventory_dir                                              = undef,
  String $oracle_base                                                              = undef,
  String $oracle_home                                                              = undef,
  Boolean $ee_options_selection                                                    = false,
  Optional[String] $ee_optional_components                                         = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  Boolean $bash_profile                                                            = true,
  String $user                                                                     = lookup('oradb::user'),
  String $user_base_dir                                                            = lookup('oradb::user_base_dir'),
  String $group                                                                    = lookup('oradb::group'),
  String $group_install                                                            = lookup('oradb::group_install'),
  String $group_oper                                                               = lookup('oradb::group_oper'),
  String $download_dir                                                             = lookup('oradb::download_dir'),
  Boolean $zip_extract                                                             = true,
  String $puppet_download_mnt_point                                                = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                                                             = true,
  Optional[String] $cluster_nodes                                                  = undef,
  Boolean $cleanup_install_files                                                   = true,
  Boolean $is_rack_one_install                                                     = false,
  String $temp_dir                                                                 = lookup('oradb::tmp_dir'),
  Optional[String] $remote_node                                                    = undef,   # hostname or ip address
)
{
  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $::kernel in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
  }

  if ( $oracle_base in $oracle_home == false ){
    fail('oracle_home folder should be under the oracle_base folder')
  }

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

  $exec_path = lookup('oradb::exec_path')

  if $puppet_download_mnt_point == undef {
    $mount_point     = 'puppet:///modules/oradb/'
  } else {
    $mount_point     = $puppet_download_mnt_point
  }

  if $ora_inventory_dir == undef {
    $ora_inventory = oradb::cleanpath("${oracle_base}/../oraInventory")
  } else {
    validate_absolute_path($ora_inventory_dir)
    $ora_inventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"oracle structure ${version}_${title}":
    ensure            => present,
    oracle_base_dir   => $oracle_base,
    ora_inventory_dir => $ora_inventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group_install,
  }

  if ( $continue ) {

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['12.2.0.1']) {
        $file1 =  "${file}.zip"
        $total_files = 1
      }

      if ( $version in ['11.2.0.1','12.1.0.1','12.1.0.2']) {
        $file1 = "${file}_1of2.zip"
        $file2 = "${file}_2of2.zip"
        $total_files = 2
      }

      if ( $version in ['11.2.0.3','11.2.0.4']) {
        $file1 = "${file}_1of7.zip"
        $file2 = "${file}_2of7.zip"
        $total_files = 2
      }

      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mount_point}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Db_directory_structure["oracle structure ${version}_${title}"],
          before  => Exec["extract ${download_dir}/${file1}"],
        }
        if ( $total_files > 1 ) {
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
        require   => Db_directory_structure["oracle structure ${version}_${title}"],
        before    => Exec["install oracle database ${title}"],
      }
      if ( $total_files > 1 ) {
        exec { "extract ${download_dir}/${file2}":
          command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file}",
          timeout   => 0,
          logoutput => false,
          path      => $exec_path,
          user      => $user,
          group     => $group,
          require   => Exec["extract ${download_dir}/${file1}"],
          before    => Exec["install oracle database ${title}"],
        }
      }
    }

    oradb::utils::dborainst{"database orainst ${version}_${title}":
      ora_inventory_dir => $ora_inventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/db_install_${version}_${title}.rsp"]) {
      file { "${download_dir}/db_install_${version}_${title}.rsp":
        ensure  => present,
        content => epp("oradb/db_install_${version}.rsp.epp",
                      { 'cluster_nodes'          => $cluster_nodes,
                        'group_install'          => $group_install,
                        'oraInventory'           => $ora_inventory,
                        'oracle_home'            => $oracle_home,
                        'oracle_base'            => $oracle_base,
                        'group_oper'             => $group_oper,
                        'group'                  => $group,
                        'database_type'          => $database_type,
                        'is_rack_one_install'    => $is_rack_one_install,
                        'ee_optional_components' => $ee_optional_components,
                        'ee_options_selection'   => $ee_options_selection }),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["database orainst ${version}_${title}"],
                    Db_directory_structure["oracle structure ${version}_${title}"],],
      }
    }

    exec { "install oracle database ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${download_dir}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/db_install_${version}_${title}.rsp'",
      creates     => "${oracle_home}/dbs",
      environment => ["USER=${user}","LOGNAME=${user}"],
      timeout     => 0,
      returns     => [6,0],
      path        => $exec_path,
      user        => $user,
      group       => $group_install,
      cwd         => $oracle_base,
      logoutput   => true,
      require     => [Oradb::Utils::Dborainst["database orainst ${version}_${title}"],
                      File["${download_dir}/db_install_${version}_${title}.rsp"]],
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

    exec { "run root.sh script ${title}":
      command   => "${oracle_home}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $exec_path,
      cwd       => $oracle_base,
      logoutput => true,
      require   => Exec["install oracle database ${title}"],
    }

    if ( $remote_node != undef) {
      # execute the scripts on the remote nodes
      exec { "run root.sh script ${title} on ${remote_node}":
        command   => "ssh ${remote_node} ${oracle_home}/root.sh",
        user      => 'root',
        group     => 'root',
        path      => $exec_path,
        cwd       => $oracle_base,
        logoutput => true,
        require   => Exec["run root.sh script ${title}"],
      }
    }

    if !defined(File[$oracle_home]) {
      file { $oracle_home:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $user,
        group   => $group_install,
        require => Exec["install oracle database ${title}","run root.sh script ${title}"],
      }
    }

    # cleanup
    if ( $cleanup_install_files ) {
      if ( $zip_extract ) {
        exec { "remove oracle db extract folder ${title}":
          command => "rm -rf ${download_dir}/${file}",
          user    => 'root',
          group   => 'root',
          path    => $exec_path,
          cwd     => $oracle_base,
          require => [Exec["install oracle database ${title}"],
                      Exec["run root.sh script ${title}"],],
          }

        if ( $remote_file == true ){
          exec { "remove oracle db file1 ${file1} ${title}":
            command => "rm -rf ${download_dir}/${file1}",
            user    => 'root',
            group   => 'root',
            path    => $exec_path,
            cwd     => $oracle_base,
            require => [Exec["install oracle database ${title}"],
                          Exec["run root.sh script ${title}"],],
          }
          exec { "remove oracle db file2 ${file2} ${title}":
            command => "rm -rf ${download_dir}/${file2}",
            user    => 'root',
            group   => 'root',
            path    => $exec_path,
            cwd     => $oracle_base,
            require => [Exec["install oracle database ${title}"],
                        Exec["run root.sh script ${title}"],],
          }
        }
      }
    }
  }
}
