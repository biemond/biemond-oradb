#
# opatch
#
# installs oracle patches for Oracle products
#
# @example opatch
#
#  oradb::opatch{'19121551_db_patch':
#    ensure                    => 'present',
#    oracle_product_home       => /app/oracle/product/11.2/db',
#    patch_id                  => '19121551',
#    patch_file                => 'p19121551_112040_Linux-x86-64.zip',
#    user                      => 'oracle',
#    group                     => 'oinstall',
#    download_dir              => '/var/tmp/install',
#    ocmrf                     => true,
#    puppet_download_mnt_point => '/software',
#  }
#
# @param oracle_product_home full path to the Oracle Home directory
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param download_dir location for installation files used by this module
# @param puppet_download_mnt_point the location where the installation software is available
# @param remote_file the installation is remote accessiable or not
# @param ensure patch should be applied or removed
# @param patch_id the opatch id
# @param patch_file the opatch patch file
# @param clusterware use opatch auto
# @param use_opatchauto_utility 
# @param bundle_sub_patch_id sub opatch id in case of a bundle patch to check if the bundle patch is already applied
# @param bundle_sub_folder just apply a patch from a bundle
# @param ocmrf
#
define oradb::opatch(
  Enum['present', 'absent'] $ensure     = 'present',
  String $oracle_product_home           = undef,
  String $patch_id                      = undef,
  String $patch_file                    = undef,
  Boolean $clusterware                  = false, # opatch auto or opatch apply
  Boolean $use_opatchauto_utility       = false,
  Optional[String] $bundle_sub_patch_id = undef,
  Optional[String] $bundle_sub_folder   = undef,
  String $user                          = lookup('oradb::user'),
  String $group                         = lookup('oradb::group'),
  String $download_dir                  = lookup('oradb::download_dir'),
  Boolean $ocmrf                        = false,
  String $puppet_download_mnt_point     = lookup('oradb::module_mountpoint'),
  Boolean $remote_file                  = true,
)
{
  $exec_path     = lookup('oradb::exec_path')
  $ora_inst_path = lookup('oradb::orainst_dir')

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
            path      => $exec_path,
            logoutput => false,
            before    => Db_opatch["${patch_id} ${title}"],
          }
        } else {
          exec { "extract opatch ${patch_file} ${title}":
            command   => "unzip -n ${puppet_download_mnt_point}/${patch_file} -d ${download_dir}",
            creates   => "${download_dir}/${patch_id}",
            path      => $exec_path,
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
          orainst_dir             => $ora_inst_path,
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
          orainst_dir             => $ora_inst_path,
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