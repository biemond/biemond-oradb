# == define: oradb::utils::dbstructure
#
#  create directories for the download, ora inventory and oracle base directories
#
#
##
define oradb::utils::dbstructure(
  $oracle_base_home_dir = undef,
  $ora_inventory_dir    = undef,
  $os_user              = undef,
  $os_group_install     = undef,
  $download_dir         = undef,
)
{
  # create all folders
  # return an array of all folders and exclude duplicates
  $dirtree_all = dirtree($oracle_base_home_dir,$ora_inventory_dir,$download_dir)
  # exclude all folders which are important for permissions
  $dirtree_all2 = delete($dirtree_all ,$oracle_base_home_dir)
  $dirtree_all3 = delete($dirtree_all2,$download_dir)
  $dirtree_all4 = delete($dirtree_all3,$ora_inventory_dir)
  # add a unique prefix, to skip already defined with multiple dbstructures in
  # same catalog like asm,db
  $dirtree_all5 = prefix($dirtree_all4,$title)
  ensure_resource('oradb::utils::dbcreatefolder', $dirtree_all5,
    {
      'prefix' => $title,
    }
  )

  # also set permissions on download dir
  # check oracle install folder
  if !defined(File[$download_dir]) {
    file { $download_dir:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0777',
    }
  }

  # also set permissions on oracle base dir
  if !defined(File[$oracle_base_home_dir]) {
    file { $oracle_base_home_dir:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $os_user,
      group   => $os_group_install,
    }
  }

  # also set permissions on ora inventory dir
  if !defined(File[$ora_inventory_dir]) {
    file { $ora_inventory_dir:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $os_user,
      group   => $os_group_install,
    }
  }
}