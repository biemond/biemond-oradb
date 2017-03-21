#
# opatchupgrade
#
# upgrades oracle opatch of an Oracle Home
#
# @example opatch upgrade
#
#  oradb::opatchupgrade{'112000_opatch_upgrade':
#    oracle_home               => '/oracle/product/11.2/db',
#    patch_file                => 'p6880880_112000_Linux-x86-64.zip',
#    csi_number                => undef,
#    support_id                => undef,
#    opversion                 => '11.2.0.3.6',
#    user                      => 'oracle',
#    group                     => 'dba',
#    download_dir              => '/install',
#    puppet_download_mnt_point => $puppet_download_mnt_point,
#  }
#
# @param oracle_home full path to the Oracle Home directory
# @param user operating system user
# @param group the operating group name for using the oracle software
# @param download_dir location for installation files used by this module
# @param puppet_download_mnt_point the location where the installation software is available
# @param patch_file the opatch upgrade patch file
# @param csi_number oracle support csi number
# @param support_id oracle support id
# @param opversion opatch version of current patch
#
define oradb::opatchupgrade(
  String $oracle_home               = undef,
  String $patch_file                = undef,
  Optional[Integer] $csi_number     = undef,
  Optional[String] $support_id      = undef,
  String $opversion                 = undef,
  String $user                      = lookup('oradb::user'),
  String $group                     = lookup('oradb::group'),
  String $download_dir              = lookup('oradb::download_dir'),
  String $puppet_download_mnt_point = lookup('oradb::module_mountpoint'),
){
  $exec_path = lookup('oradb::exec_path')
  $patch_dir = "${oracle_home}/OPatch"

  $supported_db_kernels = join( lookup('oradb::kernels'), '|')
  if ( $facts['kernel'] in $supported_db_kernels == false){
    fail("Unrecognized operating system, please use it on a ${supported_db_kernels} host")
  }

  # check the opatch version
  $installed_version = oradb::opatch_version($oracle_home)

  if $installed_version == $opversion {
    $continue = false
  } else {
    notify {"oradb::opatchupgrade ${title} ${installed_version} installed - performing upgrade":}
    $continue = true
  }

  if ( $continue ) {

    if ! defined(File["${download_dir}/${patch_file}"]) {
      file {"${download_dir}/${patch_file}":
        ensure => present,
        path   => "${download_dir}/${patch_file}",
        source => "${puppet_download_mnt_point}/${patch_file}",
        mode   => '0775',
        owner  => $user,
        group  => $group,
      }
    }

    case $facts['kernel'] {
      'Linux', 'SunOS': {
        file { $patch_dir:
          ensure  => absent,
          recurse => true,
          force   => true,
        } ->
        exec { "extract opatch ${title} ${patch_file}":
          command   => "unzip -o ${download_dir}/${patch_file} -d ${oracle_home}",
          path      => $exec_path,
          user      => $user,
          group     => $group,
          logoutput => false,
          require   => File["${download_dir}/${patch_file}"],
        }

        if ( $opversion < '12.2.0.1.5') {
          if ( $csi_number != undef and support_id != undef ) {
            exec { "exec emocmrsp ${title} ${opversion}":
              cwd       => $patch_dir,
              command   => "${patch_dir}/ocm/bin/emocmrsp -repeater NONE ${csi_number} ${support_id}",
              path      => $exec_path,
              user      => $user,
              group     => $group,
              logoutput => true,
              require   => Exec["extract opatch ${patch_file}"],
            }
          } else {

            if ! defined(Package['expect']) {
              package { 'expect':
                ensure => present,
              }
            }

            file { "${download_dir}/opatch_upgrade_${title}_${opversion}.ksh":
              ensure  => present,
              content => epp('oradb/ocm.rsp.epp', { 'patchDir' => $patch_dir }),
              mode    => '0775',
              owner   => $user,
              group   => $group,
            }

            exec { "ksh ${download_dir}/opatch_upgrade_${title}_${opversion}.ksh":
              cwd       => $patch_dir,
              path      => $exec_path,
              user      => $user,
              group     => $group,
              logoutput => true,
              require   => [File["${download_dir}/opatch_upgrade_${title}_${opversion}.ksh"],
                            Exec["extract opatch ${title} ${patch_file}"],
                            Package['expect'],],
            }
          }
        }
      }
      default: {
        fail('Unrecognized operating system')
      }
    }
  }
}
