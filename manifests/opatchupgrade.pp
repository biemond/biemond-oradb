# == Define: oradb::opatchupgrade
#
# upgrades oracle opatch
#
#
# === Examples
#
#   oradb::opatchupgrade{'112000_opatch_upgrade':
#     oracleHome => '/oracle/product/11.2/db',
#     patchFile         => '112030',
#     csiNumber         => '9999999',
#     supportId         => 'me@mycompany.com',
#     opversion         => '11.2.0.3.4',
#     user              => 'oracle',
#     group             => 'dba',
#     downloadDir       => '/install',
#     require           => Class['oradb::installdb'],
#   }
#
#
define oradb::opatchupgrade( $oracleHome              = undef,
                             $patchFile               = undef,
                             $csiNumber               = undef,
                             $supportId               = undef,
                             $opversion               = undef,
                             $user                    = 'oracle',
                             $group                   = 'dba',
                             $downloadDir             = '/install',
                             $puppetDownloadMntPoint  = undef,
)

{
  case $::kernel {
    Linux, SunOS: {

      $execPath      = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      $patchDir      = "${oracleHome}/OPatch"

      Exec { path    => $execPath,
        user         => $user,
        group        => $group,
        logoutput    => true,
      }
      File { ensure  => present,
        mode         => 0775,
        owner        => $user,
        group        => $group,
      }
    }
  }

  # check install folder
  if ! defined(File[$downloadDir]) {
    file { $downloadDir :
      mode           => 0777,
      path           => $downloadDir,
      ensure         => directory,
    }
  }

  # if a mount was not specified then get the install media from the puppet master
  if $puppetDownloadMntPoint == undef {
    $mountDir        = "puppet:///modules/oradb"
  } else {
    $mountDir        = $puppetDownloadMntPoint
  }

  # check the opatch version
  $installedVersion  = opatch_version($oracleHome)

  if $installedVersion == $opversion {
    $continue = false
  } else {
    notify {"oradb::opatchupgrade ${installedVersion} installed - performing upgrade":}
    $continue = true
  }

  if ( $continue ) {
    if ! defined(File["${downloadDir}/${patchFile}"]) {
      file {"${downloadDir}/${patchFile}":
        path         => "${downloadDir}/${patchFile}",
        ensure       => present,
        source       => "${mountDir}/${patchFile}",
        require      => File[$downloadDir],
        mode         => 0777,
      }
    }

    case $::kernel {
      Linux, SunOS: {
        file { "remove_old":
          ensure     => absent,
          recurse    => true,
          path       => $patchDir,
          force      => true,
        } ->
        exec { "extract opatch ${patchFile}":
          command    => "unzip -n ${downloadDir}/${patchFile} -d ${oracleHome}",
          require    => File ["${downloadDir}/${patchFile}"],
        }
        if $csiNumber != undef and supportId != undef {
          exec { "exec emocmrsp ${opversion}":
            cwd      => "${patchDir}",
            command  => "${patchDir}/ocm/bin/emocmrsp -repeater NONE ${csiNumber} ${supportId}",
            require  => Exec["extract opatch ${patchFile}"],
          }
        }
      }
      default: {
        fail("Unrecognized operating system")
      }
    }
  }
}
