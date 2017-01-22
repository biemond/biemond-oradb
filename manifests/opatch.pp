# == Define: oradb::opatch
#
# installs oracle patches for Oracle products
#
#
define oradb::opatch(
  Enum["present", "absent"] $ensure = 'present',
  String $oracle_product_home       = undef,
  String $patch_id                  = undef,
  String $patch_file                = undef,
  Boolean $clusterware              = false, # opatch auto or opatch apply
  Boolean $use_opatchauto_utility   = false,
  Optional[String] $bundle_sub_patch_id = undef,
  Optional[String] $bundle_sub_folder   = undef,
  String $user                      = lookup('oradb::user'),
  String $group                     = lookup('oradb::group'),
  String $download_dir              = lookup('oradb::download_dir'),
  Boolean $ocmrf                    = false,
  String $puppet_download_mnt_point = lookup('oradb::module_mountpoint'),
  Boolean $remote_file              = true,
)
{
  $execPath    = lookup('oradb::exec_path')
  $oraInstPath = lookup('oradb::orainst_dir')

  if $ensure == 'present' {
    if $remote_file == true {
      # the patch used by the opatch
      if ! defined(File["${download_dir}/${patch_file}"]) {
        file { "${download_dir}/${patch_file}":
          ensure => present,
          source => "${puppet_download_mnt_point}/${patch_file}",
          mode   => '0775'
        }
      }
    }
  }

  case $facts['kernel'] {
    'Linux', 'SunOS': {
      if $ensure == 'present' {
        if $remote_file == true {
          exec { "extract opatch ${patch_file} ${title}":
            command   => "unzip -n ${download_dir}/${patch_file} -d ${download_dir}",
            require   => File["${download_dir}/${patch_file}"],
            creates   => "${download_dir}/${patch_id}",
            path      => $execPath,
            logoutput => false,
            before    => Db_opatch["${patch_id} ${title}"],
          }
        } else {
          exec { "extract opatch ${patch_file} ${title}":
            command   => "unzip -n ${puppet_download_mnt_point}/${patch_file} -d ${download_dir}",
            creates   => "${download_dir}/${patch_id}",
            path      => $execPath,
            user      => $user,
            group     => $group,
            logoutput => false,
            before    => Db_opatch["${patch_id} ${title}"],
          }
        }
      }

      # sometimes the bundle patch inside an other folder
      if ( $bundle_sub_folder ) {
        $extracted_patch_dir = "${download_dir}/${patch_id}/${bundle_sub_folder}"
      } else {
        $extracted_patch_dir = "${download_dir}/${patch_id}"
      }

      if $ocmrf == true {

        db_opatch{ "${patch_id} ${title}":
          ensure                  => $ensure,
          patch_id                => $patch_id,
          os_user                 => $user,
          oracle_product_home_dir => $oracle_product_home,
          orainst_dir             => $oraInstPath,
          extracted_patch_dir     => $extracted_patch_dir,
          ocmrf_file              => "${oracle_product_home}/OPatch/ocm.rsp",
          bundle_sub_patch_id     => $bundle_sub_patch_id,
          opatch_auto             => $clusterware,
          use_opatchauto_utility  => $use_opatchauto_utility,
        }

      } else {

        db_opatch{ "${patch_id} ${title}":
          ensure                  => $ensure,
          patch_id                => $patch_id,
          os_user                 => $user,
          oracle_product_home_dir => $oracle_product_home,
          orainst_dir             => $oraInstPath,
          extracted_patch_dir     => $extracted_patch_dir,
          bundle_sub_patch_id     => $bundle_sub_patch_id,
          opatch_auto             => $clusterware,
          use_opatchauto_utility  => $use_opatchauto_utility,
        }

      }
    }
    default: {
      fail('Unrecognized operating system')
    }
  }
}