# == Define: oradb::opatch
#
# installs oracle patches for Oracle products
#
#
define oradb::opatch(
  String $ensure = 'present',  # Enum['present','absent']
  String $oracle_product_home       = undef,
  String $patch_id                  = undef,
  String $patch_file                = undef,
  Boolean $clusterware              = false, # opatch auto or opatch apply
  Boolean $use_opatchauto_utility   = false,
  String $bundle_sub_patch_id       = undef,
  String $bundle_sub_folder         = undef,
  String $user                      = hiera('oradb:user'),
  String $group                     = hiera('oradb:group'),
  String $download_dir              = hiera('oradb:download_dir'),
  Boolean $ocmrf                    = false,
  String $puppet_download_mnt_point = hiera('oradb:module_mountpoint'),
  Boolean $remote_file              = true,
)
{
  $execPath    = hiera('oradb:exec_path')
  $oraInstPath = hiera('oradb:orainst_dir')

  if $ensure == 'present' {
    if $remote_file == true {
      # the patch used by the opatch
      if ! defined(File["${download_dir}/${patch_file}"]) {
        file { "${download_dir}/${patch_file}":
          ensure => present,
          source => "${mountPoint}/${patch_file}",
          mode   => '0775',
          owner  => $user,
          group  => $group,
        }
      }
    }
  }

  case $::kernel {
    'Linux', 'SunOS': {
      if $ensure == 'present' {
        if $remote_file == true {
          exec { "extract opatch ${patch_file} ${title}":
            command   => "unzip -n ${download_dir}/${patch_file} -d ${download_dir}",
            require   => File["${download_dir}/${patch_file}"],
            creates   => "${download_dir}/${patch_id}",
            path      => $execPath,
            user      => $user,
            group     => $group,
            logoutput => false,
            before    => Db_opatch["${patch_id} ${title}"],
          }
        } else {
          exec { "extract opatch ${patch_file} ${title}":
            command   => "unzip -n ${mountPoint}/${patch_file} -d ${download_dir}",
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