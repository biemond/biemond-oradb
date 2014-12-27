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
define oradb::opatchupgrade(
  $oracleHome              = undef,
  $patchFile               = undef,
  $csiNumber               = undef,
  $supportId               = undef,
  $opversion               = undef,
  $user                    = 'oracle',
  $group                   = 'dba',
  $downloadDir             = '/install',
  $puppetDownloadMntPoint  = undef,
){
  $execPath      = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
  $patchDir      = "${oracleHome}/OPatch"

  # if a mount was not specified then get the install media from the puppet master
  if $puppetDownloadMntPoint == undef {
    $mountDir        = 'puppet:///modules/oradb'
  } else {
    $mountDir        = $puppetDownloadMntPoint
  }

  # check the opatch version
  $installedVersion  = opatch_version($oracleHome)

  if $installedVersion == $opversion {
    $continue = false
  } else {
    notify {"oradb::opatchupgrade ${title} ${installedVersion} installed - performing upgrade":}
    $continue = true
  }

  if ( $continue ) {

    if ! defined(File["${downloadDir}/${patchFile}"]) {
      file {"${downloadDir}/${patchFile}":
        ensure  => present,
        path    => "${downloadDir}/${patchFile}",
        source  => "${mountDir}/${patchFile}",
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => File[$downloadDir],
      }
    }

    case $::kernel {
      'Linux', 'SunOS': {
        file { $patchDir:
          ensure  => absent,
          recurse => true,
          force   => true,
        } ->
        exec { "extract opatch ${title} ${patchFile}":
          command   => "unzip -o ${downloadDir}/${patchFile} -d ${oracleHome}",
          require   => File["${downloadDir}/${patchFile}"],
          path      => $execPath,
          user      => $user,
          group     => $group,
          logoutput => false,
        }

        if ( $csiNumber != undef and supportId != undef ) {
          exec { "exec emocmrsp ${title} ${opversion}":
            cwd       => $patchDir,
            command   => "${patchDir}/ocm/bin/emocmrsp -repeater NONE ${csiNumber} ${supportId}",
            require   => Exec["extract opatch ${patchFile}"],
            path      => $execPath,
            user      => $user,
            group     => $group,
            logoutput => true,
          }
        } else {

          if ! defined(Package['expect']) {
            package { 'expect':
              ensure  => present,
            }
          }

          file { "${downloadDir}/opatch_upgrade_${title}_${opversion}.ksh":
            ensure  => present,
            content => template('oradb/ocm.rsp.erb'),
            mode    => '0775',
            owner   => $user,
            group   => $group,
            require => File[$downloadDir],
          }

          exec { "ksh ${downloadDir}/opatch_upgrade_${title}_${opversion}.ksh":
            cwd       => $patchDir,
            require   => [File["${downloadDir}/opatch_upgrade_${title}_${opversion}.ksh"],
                          Exec["extract opatch ${title} ${patchFile}"],
                          Package['expect'],],
            path      => $execPath,
            user      => $user,
            group     => $group,
            logoutput => true,
          }
        }

      }
      default: {
        fail('Unrecognized operating system')
      }
    }
  }
}
