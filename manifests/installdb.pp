# == Class: oradb::installdb
#
# The database_type value should contain only one of these choices.
# EE     : Enterprise Edition
# SE     : Standard Edition
# SEONE  : Standard Edition One
#
#
define oradb::installdb(
  String $version                          = undef,
  String $file                             = undef,
  Enum["SE", "EE", "SEONE"] $database_type = lookup('oradb:installdb:database_type'),
  Optional[String] $ora_inventory_dir      = undef,
  String $oracle_base                      = undef,
  String $oracle_home                      = undef,
  Boolean $ee_options_selection            = false,
  Optional[String] $ee_optional_components = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  Boolean $bash_profile                    = true,
  String $user                             = lookup('oradb::user'),
  String $user_base_dir                    = lookup('oradb::user_base_dir'),
  String $group                            = lookup('oradb::group'),
  String $group_install                    = lookup('oradb::group_install'),
  String $group_oper                       = lookup('oradb::group_oper'),
  String $download_dir                     = lookup('oradb::download_dir'),
  Boolean $zip_extract                     = true,
  String $puppet_download_mnt_point        = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                     = true,
  Optional[String] $cluster_nodes          = undef,
  Boolean $cleanup_install_files           = true,
  Boolean $is_rack_one_install             = false,
  String $temp_dir                         = '/tmp',
  Optional[String] $remote_node            = undef,   # hostname or ip address
)
{
  $supported_db_versions = join( lookup('oradb::versions'), '|')
  if ( $version in $supported_db_versions == false ){
    fail("Unrecognized database install version, use ${supported_db_versions}")
  }

  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $::kernel in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
  }

  $supported_db_types = join( lookup('oradb::database_types'), '|')
  if ( $database_type in $supported_db_types == false){
    fail("Unrecognized database type, please use ${supported_db_types}")
  }

  if ( $oracle_base == undef or is_string($oracle_base) == false) {fail('You must specify an oracle_base') }
  if ( $oracle_home == undef or is_string($oracle_home) == false) {fail('You must specify an oracle_home') }

  if ( $oracle_base in $oracle_home == false ){
    fail('oracle_home folder should be under the oracle_base folder')
  }

  # check if the oracle software already exists
  $found = oracle_exists( $oracle_home )

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
    $mountPoint     = 'puppet:///modules/oradb/'
  } else {
    $mountPoint     = $puppet_download_mnt_point
  }

  if $ora_inventory_dir == undef {
    $oraInventory = pick($::oradb_inst_loc_data,oradb_cleanpath("${oracle_base}/../oraInventory"))
  } else {
    validate_absolute_path($ora_inventory_dir)
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"oracle structure ${version}_${title}":
    ensure            => present,
    oracle_base_dir   => $oracle_base,
    ora_inventory_dir => $oraInventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group_install,
  }

  if ( $continue ) {

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['11.2.0.1','12.1.0.1','12.1.0.2']) {
        $file1 =  "${file}_1of2.zip"
        $file2 =  "${file}_2of2.zip"
      }

      if ( $version in ['11.2.0.3','11.2.0.4']) {
        $file1 =  "${file}_1of7.zip"
        $file2 =  "${file}_2of7.zip"
      }

      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mountPoint}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Db_directory_structure["oracle structure ${version}_${title}"],
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
        $source = $download_dir
      } else {
        $source = $mountPoint
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

    oradb::utils::dborainst{"database orainst ${version}_${title}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/db_install_${version}_${title}.rsp"]) {
      file { "${download_dir}/db_install_${version}_${title}.rsp":
        ensure  => present,
        content => epp("oradb/db_install_${version}.rsp.epp", {'cluster_nodes'          => $cluster_nodes,
                                                               'group_install'          => $group_install,
                                                               'oraInventory'           => $oraInventory,
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
