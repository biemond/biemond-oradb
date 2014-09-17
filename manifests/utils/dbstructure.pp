# == define: oradb::utils::dbstructure
#
#  create directories for the download folder and oracle base home
#
#
##
define oradb::utils::dbstructure (
  $oracle_base_home_dir = undef,
  $ora_inventory_dir    = undef,
  $os_user              = undef,
  $os_group             = undef,
  $os_group_install     = undef,
  $os_group_oper        = undef,
  $download_dir         = undef,
  $log_output           = false,
  $user_base_dir        = undef,
  $create_user          = true, ) {

  $exec_path = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

  Exec {
    logoutput => $log_output,
  }

  if ( $create_user ) {
    # Whether Puppet will manage the group or relying on external methods
    if ! defined(Group[$os_group]) {
      group { $os_group :
        ensure => present,
        before => User[$os_user],
      }
    }
    if ! defined(Group[$os_group_install]) {
      group { $os_group_install :
        ensure => present,
        before => User[$os_user],
      }
    }
    if ( $os_group_oper != undef ){
      if ! defined(Group[$os_group_oper]) {
        group { $os_group_oper :
          ensure => present,
          before => User[$os_user],
        }
      }
      $all_groups = [$os_group,$os_group_install,$os_group_oper ]
    } else {
      $all_groups = [$os_group,$os_group_install]
    }
    # Whether Puppet will manage the user or relying on external methods
    if ! defined(User[$os_user]) {
      # http://raftaman.net/?p=1311 for generating password
      user { $os_user :
        ensure     => present,
        gid        => $os_group_install,
        groups     => $all_groups,
        shell      => '/bin/bash',
        password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
        home       => "${user_base_dir}/${os_user}",
        comment    => "This user ${os_user} was created by Puppet",
        managehome => true,
      }
    }
  }

  # create all folders
  if !defined(Exec["create ${oracle_base_home_dir} directory"]) {
    exec { "create ${oracle_base_home_dir} directory":
      command => "mkdir -p ${oracle_base_home_dir}",
      unless  => "test -d ${oracle_base_home_dir}",
      user    => 'root',
      path    => $exec_path,
    }
  }

  if !defined(Exec["create ${download_dir} home directory"]) {
    exec { "create ${download_dir} home directory":
      command => "mkdir -p ${download_dir}",
      unless  => "test -d ${download_dir}",
      user    => 'root',
      path    => $exec_path,
    }
  }

  if ( $create_user == true ) {

    # also set permissions on downloadDir
    if !defined(File[$download_dir]) {
      # check oracle install folder
      file { $download_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => [Exec["create ${download_dir} home directory"],
                    User[$os_user],
                    ],
      }
    }
    # also set permissions on oracleHome
    if !defined(File[$oracle_base_home_dir]) {
      file { $oracle_base_home_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => [Exec["create ${oracle_base_home_dir} directory"],
                    User[$os_user],
                    ],
      }
    }
    # also set permissions on oraInventory
    if !defined(File[$ora_inventory_dir]) {
      file { $ora_inventory_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => [Exec["create ${oracle_base_home_dir} directory"],
                    File[$oracle_base_home_dir],
                    User[$os_user],
                    ],
      }
    }

  } else {
    # also set permissions on downloadDir
    if !defined(File[$download_dir]) {
      # check oracle install folder
      file { $download_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => [Exec["create ${download_dir} home directory"],],
      }
    }

    # also set permissions on oracleHome
    if !defined(File[$oracle_base_home_dir]) {
      file { $oracle_base_home_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => Exec["create ${oracle_base_home_dir} directory"],
      }
    }

    # also set permissions on oraInventory
    if !defined(File[$ora_inventory_dir]) {
      file { $ora_inventory_dir:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group_install,
        require => [Exec["create ${oracle_base_home_dir} directory"],
                    File[$oracle_base_home_dir],
                    ],
      }
    }
  }
}