# == Class: oradb::installasm
#
#
define oradb::installasm(
  $version                   = undef,
  $file                      = undef,
  $grid_type                 = 'HA_CONFIG', #CRS_CONFIG|HA_CONFIG|UPGRADE|CRS_SWONLY
  $stand_alone               = true, # in case of 'CRS_SWONLY' and used as stand alone or in RAC
  $grid_base                 = undef,
  $grid_home                 = undef,
  $ora_inventory_dir         = undef,
  $user                      = 'grid',
  $user_base_dir             = '/home',
  $group                     = 'asmdba',
  $group_install             = 'oinstall',
  $group_oper                = 'asmoper',
  $group_asm                 = 'asmadmin',
  $sys_asm_password          = 'Welcome01',
  $asm_monitor_password      = 'Welcome01',
  $asm_diskgroup             = 'DATA',
  $disk_discovery_string     = undef,
  $disk_redundancy           = 'NORMAL',
  $disk_au_size              = 1,
  $disks                     = undef,
  $download_dir              = '/install',
  $zip_extract                = true,
  $puppet_download_mnt_point = undef,
  $remote_file               = true,
  $cluster_name              = undef,
  $scan_name                 = undef,
  $scan_port                 = undef,
  $cluster_nodes             = undef,
  $network_interface_list    = undef,
  $storage_option            = undef,
  $temp_dir                  = '/tmp',
  $remote_node               = undef, # hostname or ip address
)
{

  case $disk_au_size {
    1, 2, 4, 8, 16, 32, 64: {  } # Do nothing. These are valid values
    default: {
      fail("${disk_au_size} is an invalid disk_au_size. It needs to be one of these values: 1, 2, 4, 8, 16, 32, 64")
    }
  }
  $file_without_ext = regsubst($file, '(.+?)(\.zip*$|$)', '\1')
  #notify {"oradb::installasm file without extension ${$file_without_ext} ":}

  if($cluster_name){ # We've got a RAC cluster. Check the cluster specific parameters
    if ( $scan_name == undef or is_string($scan_name) == false) {fail('You must specify scan_name if cluster_name is defined') }
    if ( $scan_port == undef or is_integer($scan_port) == false) {fail('You must specify scan_port if cluster_name is defined') }
    if ( $cluster_nodes == undef or is_string($cluster_nodes) == false) {fail('You must specify cluster_nodes if cluster_name is defined') }
    if ( $network_interface_list == undef or is_string($network_interface_list) == false) {fail('You must specify network_interface_list if cluster_name is defined') }
    if ( $storage_option == undef or is_string($storage_option) == false) {fail('You must specify storage_option if cluster_name is defined') }
    unless $storage_option in ['ASM_STORAGE', 'FILE_SYSTEM_STORAGE'] {fail 'storage_option must be either ASM_STORAGE of FILE_SYSTEM_STORAGE'}
  }

  if (!( $version in ['11.2.0.4','12.1.0.1', '12.1.0.2'] )){
    fail('Unrecognized database grid install version, use 11.2.0.4, 12.1.0.1 or 12.1.0.2')
  }

  if ($grid_type == 'CRS_CONFIG' and $remote_node == undef) {
    fail('You must specify remote_node if grid_type is CRS_CONFIG')
  }

  if ( !($::kernel in ['Linux','SunOS'])){
    fail('Unrecognized operating system, please use it on a Linux or SunOS host')
  }

  if ( !($grid_type in ['CRS_CONFIG','HA_CONFIG','UPGRADE','CRS_SWONLY'])){
    fail('Unrecognized database grid type, please use CRS_CONFIG|HA_CONFIG|UPGRADE|CRS_SWONLY')
  }

  if ( $grid_base == undef or is_string($grid_base) == false) {fail('You must specify an grid_base') }
  if ( $grid_home == undef or is_string($grid_home) == false) {fail('You must specify an grid_home') }

  # check if the oracle software already exists
  $found = oracle_exists( $grid_home )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installasm ${grid_home} does not exists":}
      $continue = true
    }
  }

  if $ora_inventory_dir == undef {
    $oraInventory = pick($::oradb_inst_loc_data,oradb_cleanpath("${grid_base}/../oraInventory"))
  } else {
    validate_absolute_path($ora_inventory_dir)
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"grid structure ${version}":
    ensure            => present,
    oracle_base_dir   => $grid_base,
    ora_inventory_dir => $oraInventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group_install,
  }

  if ( $continue ) {

    $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

    if $puppet_download_mnt_point == undef {
      $mountPoint     = 'puppet:///modules/oradb/'
    } else {
      $mountPoint     = $puppet_download_mnt_point
    }

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if versioncmp($version, '12.1.0.1') >= 0 {
        $file1 =  "${file}_1of2.zip"
        $file2 =  "${file}_2of2.zip"
      }
      if ( $version  == '11.2.0.4' ) {
        $file1 =  $file
      }

      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mountPoint}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Db_directory_structure["grid structure ${version}"],
          before  => Exec["extract ${download_dir}/${file1}"],
        }

        if versioncmp($version, '12.1.0.1') >= 0 {
          file { "${download_dir}/${file2}":
            ensure  => present,
            source  => "${mountPoint}/${file2}",
            mode    => '0775',
            owner   => $user,
            group   => $group,
            require => File["${download_dir}/${file1}"],
            before  => Exec["extract ${download_dir}/${file2}"]
          }
        }

        $source = $download_dir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${download_dir}/${file1}":
        command   => "unzip -o ${source}/${file1} -d ${download_dir}/${file_without_ext}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        creates   => "${download_dir}/${file_without_ext}",
        require   => Db_directory_structure["grid structure ${version}"],
        before    => Exec["install oracle grid ${title}"],
      }
      if versioncmp($version, '12.1.0.1') >= 0 {
        exec { "extract ${download_dir}/${file2}":
          command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file_without_ext}",
          timeout   => 0,
          logoutput => false,
          path      => $execPath,
          user      => $user,
          group     => $group,
          require   => Exec["extract ${download_dir}/${file1}"],
          before    => Exec["install oracle grid ${title}"],
        }
      }
    }

    oradb::utils::dborainst{"grid orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/grid_install_${version}.rsp"]) {
      file { "${download_dir}/grid_install_${version}.rsp":
        ensure  => present,
        content => template("oradb/grid_install_${version}.rsp.erb"),
        mode    => '0770',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["grid orainst ${version}"],
                    Db_directory_structure["grid structure ${version}"],],
      }
    }

    exec { "install oracle grid ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${download_dir}/${file_without_ext}/grid/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/grid_install_${version}.rsp'",
      creates     => "${grid_home}/bin",
      environment => ["USER=${user}","LOGNAME=${user}"],
      timeout     => 0,
      returns     => [6,0],
      path        => $execPath,
      user        => $user,
      group       => $group_install,
      cwd         => $grid_base,
      logoutput   => true,
      require     => [Oradb::Utils::Dborainst["grid orainst ${version}"],
                      File["${download_dir}/grid_install_${version}.rsp"]],
    }

    if ! defined(File["${user_base_dir}/${user}/.bash_profile"]) {
      file { "${user_base_dir}/${user}/.bash_profile":
        ensure  => present,
        # content => template('oradb/grid_bash_profile.erb'),
        content => regsubst(template('oradb/grid_bash_profile.erb'), '\r\n', "\n", 'EMG'),
        mode    => '0775',
        owner   => $user,
        group   => $group,
      }
    }

    #because of RHEL7 uses systemd we need to create the service differently
    if ($::osfamily == 'RedHat') and ($::operatingsystemmajrelease == '7')
    {
      file {'/etc/systemd/system/oracle-ohasd.service':
        ensure  => 'file',
        content => template('oradb/ohas.service.erb'),
        mode    => '0644',
        require => Exec["install oracle grid ${title}"],
      } ->

      exec { 'daemon-reload for ohas':
        command => '/bin/systemctl daemon-reload',
      } ->

      service { 'ohas.service':
        ensure => running,
        enable => true,
        before => Exec["run root.sh grid script ${title}"],
      }
    }

    exec { "run root.sh grid script ${title}":
      timeout   => 0,
      command   => "${grid_home}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      cwd       => $grid_base,
      logoutput => true,
      require   => Exec["install oracle grid ${title}"],
    }
    
    if ($grid_type == 'CRS_CONFIG') {     
      # execute the scripts on the remote nodes
      exec { "run orainstRoot.sh grid script ${title} on ${remote_node}":
        timeout   => 0,
        command   => "ssh ${remote_node} ${$oraInventory}/orainstRoot.sh",
        user      => 'root',
        group     => 'root',
        path      => $execPath,
        cwd       => $grid_base,
        logoutput => true,
        require   => Exec["run root.sh grid script ${title}"],
      }
      
      exec { "run root.sh grid script ${title} on ${remote_node}":
        timeout   => 0,
        command   => "ssh ${remote_node} ${grid_home}/root.sh",
        user      => 'root',
        group     => 'root',
        path      => $execPath,
        cwd       => $grid_base,
        logoutput => true,
        require   => Exec["run orainstRoot.sh grid script ${title} on ${remote_node}"],
        before    => Exec["run configToolAllCommands grid tool ${title}"],
      }
    }

    file { $grid_home:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group_install,
      require => Exec["install oracle grid ${title}","run root.sh grid script ${title}"],
    }

    # cleanup
    if ( $zip_extract ) {
      exec { "remove oracle asm extract folder ${title}":
        command => "rm -rf ${download_dir}/${file_without_ext}",
        user    => 'root',
        group   => 'root',
        path    => $execPath,
        require => Exec["install oracle grid ${title}"],
      }

      if ( $remote_file == true ){
        if versioncmp($version, '12.1.0.1') >= 0 {
          exec { "remove oracle asm file2 ${file2} ${title}":
            command => "rm -rf ${download_dir}/${file2}",
            user    => 'root',
            group   => 'root',
            path    => $execPath,
            require => Exec["install oracle grid ${title}"],
          }
        }

        exec { "remove oracle asm file1 ${file1} ${title}":
          command => "rm -rf ${download_dir}/${file1}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          require => Exec["install oracle grid ${title}"],
        }
      }
    }

    if ( $grid_type == 'CRS_SWONLY' ) {
      if ( $stand_alone == true ) {
        exec { 'Configuring Grid Infrastructure for a Stand-Alone Server':
          command   => "${grid_home}/perl/bin/perl -I${grid_home}/perl/lib -I${grid_home}/crs/install ${grid_home}/crs/install/roothas.pl",
          user      => 'root',
          group     => 'root',
          path      => $execPath,
          cwd       => $grid_base,
          logoutput => true,
          require   => [Exec["run root.sh grid script ${title}"],
                        File[$grid_home],],
        }
      }
    } else {
      file { "${download_dir}/cfgrsp.properties":
        ensure  => present,
        content => template('oradb/grid_password.properties.erb'),
        mode    => '0600',
        owner   => $user,
        group   => $group,
        require => [Exec["run root.sh grid script ${title}"],
                    File[$grid_home],],
      }

      exec { "run configToolAllCommands grid tool ${title}":
        timeout   => 0, # This can sometimes take a long time
        command   => "${grid_home}/cfgtoollogs/configToolAllCommands RESPONSE_FILE=${download_dir}/cfgrsp.properties",
        user      => $user,
        group     => $group_install,
        path      => $execPath,
        provider  => 'shell',
        cwd       => "${grid_home}/cfgtoollogs",
        logoutput => true,
        returns   => [0,3], # when a scan adress is not defined in the DNS, it fails, buut we can continue
        require   => [File["${download_dir}/cfgrsp.properties"],
                      Exec["run root.sh grid script ${title}"],
                      Exec["install oracle grid ${title}"],
                      ],
      }
    }

  }
}
