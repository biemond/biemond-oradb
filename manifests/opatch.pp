# == Define: oradb::opatch
#
# installs oracle patches for Oracle products
#
#
# === Examples
#  oradb::opatch{'14727310_db_patch':
#    oracleProductHome => '/oracle/product/11.2/db',
#    patchId           => '14727310',
#    patchFile         => 'p14727310_112030_Linux-x86-64.zip',
#    user              => 'oracle',
#    group             => 'dba',
#    downloadDir       => '/install',
#    ocmrf             => 'true',
#    require           => Class['oradb::installdb'],
#  }
#
#
define oradb::opatch( $oracleProductHome       = undef,
                      $patchId                 = undef,
                      $patchFile               = undef,
                      $user                    = 'oracle',
                      $group                   = 'dba',
                      $downloadDir             = '/install',
                      $ocmrf                   = true,
                      $puppetDownloadMntPoint  = undef,
                      $remoteFile              = true,
)

{
  case $::kernel {
    Linux, SunOS: {
      $execPath      = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
      $path          = $downloadDir

      Exec { path    => $execPath,
        user         => $user,
        group        => $group,
        logoutput    => true,
      }
      File {
        ensure       => present,
        mode         => 0775,
        owner        => $user,
        group        => $group,
      }
    }
    default: {
      fail("Unrecognized operating system")
    }
  }

  # check if the opatch already is installed
  $found = opatch_exists($oracleProductHome,$patchId)
  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::opatch ${title} ${oracleProductHome} does not exists":}
      $continue = true
    }
  }

  if ( $continue ) {
    if $puppetDownloadMntPoint == undef {
      $mountPoint    = "puppet:///modules/oradb/"
    } else {
      $mountPoint    =	$puppetDownloadMntPoint
    }

    if $remoteFile == true {
	    # the patch used by the opatch
	    if ! defined(File["${path}/${patchFile}"]) {
	      file { "${path}/${patchFile}":
	        source       => "${mountPoint}/${patchFile}",
	      }
	    }
    }

    # opatch apply -silent -oh /oracle/product/11.2/db /install/14389126
    $oPatchCommand   = "opatch apply -silent "

    case $::kernel {
      Linux, SunOS: {
        if $remoteFile == true {
	        exec { "extract opatch ${patchFile} ${title}":
	          command    => "unzip -n ${path}/${patchFile} -d ${path}",
	          require    => File ["${path}/${patchFile}"],
	          creates    => "${path}/${patchId}",
	        }
        } else {
          exec { "extract opatch ${patchFile} ${title}":
            command    => "unzip -n ${mountPoint}/${patchFile} -d ${path}",
            creates    => "${path}/${patchId}",
          }
        }
        if $ocmrf == true {
          exec { "exec opatch ux ocmrf ${title}":
            command  => "${oracleProductHome}/OPatch/${oPatchCommand} -ocmrf ${oracleProductHome}/OPatch/ocm.rsp -oh ${oracleProductHome} ${path}/${patchId}",
            require  => Exec["extract opatch ${patchFile} ${title}"],
          }
        } else {
          exec { "exec opatch ux ${title}":
            command  => "${oracleProductHome}/OPatch/${oPatchCommand} -oh ${oracleProductHome} ${path}/${patchId}",
            require  => Exec["extract opatch ${patchFile} ${title}"],
          }
        }
      }
      default: {
        fail("Unrecognized operating system")
      }
    }
  }
}
