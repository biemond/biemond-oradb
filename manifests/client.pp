# == Class: oradb::client
#
#
define oradb::client(
  $version                   = undef,
  $file                      = undef,
  $oracle_base               = undef,
  $oracle_home               = undef,
  $ora_inventory_dir         = undef,
  $db_port                   = '1521',
  $user                      = 'oracle',
  $user_base_dir             = '/home',
  $group                     = 'dba',
  $group_install             = 'oinstall',
  $download_dir              = '/install',
  $bash_profile              = true,
  $puppet_download_mnt_point = undef,
  $remote_file               = true,
  $logoutput                 = true,
)
{
  validate_absolute_path($oracle_home)
  validate_absolute_path($oracle_base)

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

  if $ora_inventory_dir == undef {
    $oraInventory = pick($::oradb_inst_loc_data,oradb_cleanpath("${oracle_base}/../oraInventory"))
  } else {
    validate_absolute_path($ora_inventory_dir)
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"client structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base,
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

    # db file installer zip
    if $remote_file == true {
      file { "${download_dir}/${file}":
        ensure  => present,
        source  => "${mountPoint}/${file}",
        before  => Exec["extract ${download_dir}/${file}"],
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Db_directory_structure["client structure ${version}"],
      }
      $source = $download_dir
    } else {
      $source = $mountPoint
    }
    exec { "extract ${download_dir}/${file}":
      command   => "unzip -o ${source}/${file} -d ${download_dir}/client_${version}",
      timeout   => 0,
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => false,
      require   => Db_directory_structure["client structure ${version}"],
    }

    oradb::utils::dborainst{"oracle orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/db_client_${version}.rsp"]) {
      file { "${download_dir}/db_client_${version}.rsp":
        ensure  => present,
        content => template("oradb/db_client_${version}.rsp.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["oracle orainst ${version}"],
                    Db_directory_structure["client structure ${version}"],],
      }
    }

    # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.
    exec { "install oracle client ${title}":
      command   => "/bin/sh -c 'unset DISPLAY;${download_dir}/client_${version}/client/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/db_client_${version}.rsp'",
      require   => [Oradb::Utils::Dborainst["oracle orainst ${version}"],
                    File["${download_dir}/db_client_${version}.rsp"],
                    Exec["extract ${download_dir}/${file}"]],
      creates   => $oracle_home,
      timeout   => 0,
      returns   => [6,0],
      path      => $execPath,
      user      => $user,
      group     => $group_install,
      logoutput => $logoutput,
    }

    exec { "run root.sh script ${title}":
      command   => "${oracle_home}/root.sh",
      user      => 'root',
      group     => 'root',
      require   => Exec["install oracle client ${title}"],
      path      => $execPath,
      logoutput => $logoutput,
    }

    file { "${download_dir}/netca_client_${version}.rsp":
      ensure  => present,
      content => template("oradb/netca_client_${version}.rsp.erb"),
      require => Exec["run root.sh script ${title}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }

    exec { "install oracle net ${title}":
      command   => "${oracle_home}/bin/netca /silent /responsefile ${download_dir}/netca_client_${version}.rsp",
      require   => [File["${download_dir}/netca_client_${version}.rsp"],Exec["run root.sh script ${title}"],],
      creates   => "${oracle_home}/network/admin/sqlnet.ora",
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => $logoutput,
    }

    if ( $bash_profile == true ) {
      if ! defined(File["${user_base_dir}/${user}/.bash_profile"]) {
        file { "${user_base_dir}/${user}/.bash_profile":
          ensure  => present,
          # content => template('oradb/bash_profile.erb'),
          content => regsubst(template('oradb/bash_profile.erb'), '\r\n', "\n", 'EMG'),
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
      path    => $execPath,
      require => Exec["install oracle net ${title}"],
    }

    if ( $remote_file == true ){
      exec { "remove oracle client file ${file} ${title}":
        command => "rm -rf ${download_dir}/${file}",
        user    => 'root',
        group   => 'root',
        path    => $execPath,
        require => Exec["install oracle net ${title}"],
      }
    }

  }
}
