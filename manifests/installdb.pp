# == Class: oradb::installdb
#
# The databaseType value should contain only one of these choices.        
# EE     : Enterprise Edition                                
# SE     : Standard Edition                                  
# SEONE  : Standard Edition One
#
#    oradb::installdb{ '112030_Linux-x86-64':
#            version      => '11.2.0.3', 
#            file         => 'p10404530_112030_Linux-x86-64',
#            databaseType => 'SE',
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            user         => 'oracle',
#            group        => 'dba',
#            downloadDir  => '/install',  
#         }
#
#    oradb::installdb{ '112010_Linux-x86-64':
#            version      => '11.2.0.1', 
#            file         => 'linux.x64_11gR2_database',
#            databaseType => 'SE',
#            oracleBase   => '/oracle',
#            oracleHome   => '/oracle/product/11.2/db',
#            user         => 'oracle',
#            group        => 'dba',
#            downloadDir  => '/install',  
#         }
#
#
#

define oradb::installdb( $version      = undef,
                         $file         = undef,
                         $databaseType = 'SE',
                         $oracleBase   = undef,
                         $oracleHome   = undef,
                         $user         = 'oracle',
                         $group        = 'dba',
                         $downloadDir  = '/install',
                         $puppetDownloadMntPoint  = undef,      
    )
  
  {


  # check if the oracle software already exists
  $found = oracle_exists( $oracleHome )
  if $found == undef {
       $continue = true
  } else {
       if ( $found ) {
         notify {"oradb::installdb ${oracleHome} already exists":}
         $continue = false
       } else {
         notify {"oradb::installdb ${oracleHome} does not exists":}
         $continue = true 
       }
  }

if ( $continue ) {


   case $operatingsystem {
     CentOS, RedHat, OracleLinux, Ubuntu, Debian, SLES: { 

        $execPath        = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
        $path            = $downloadDir
        $oraInstPath     = "/etc"
        $oraInventory    = "${oracleBase}/oraInventory"
        
        Exec { path      => $execPath,
               user      => $user,
               group     => $group,
               logoutput => true,
             }
        File {
               ensure  => present,
               mode    => 0775,
               owner   => $user,
               group   => $group,
             }        
     }
     default: { 
        fail("Unrecognized operating system") 
     }
   }

   if $puppetDownloadMntPoint == undef {
     $mountPoint =  "puppet:///modules/oradb/"      
   } else {
     $mountPoint =  $puppetDownloadMntPoint
   }

   if ! defined(Group[$group]) {
      group { $group : 
              ensure => present,
      }
   }

   if ! defined(User[$user]) {
      # http://raftaman.net/?p=1311 for generating password
      user { $user : 
              ensure     => present, 
              groups     => $group,
              shell      => '/bin/bash',
              password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',  
              home       => "/home/${user}",
              comment    => 'This user ${user} was created by Puppet',
              require    => Group[$group],
              managehome => true, 
       }
   }


   if ! defined(File[$path]) {
      # check oracle install folder
      file { $path :
        path    => $path,
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

if $version == '12.1.0.1' {  

   # db file 1 installer zip
   file { "${path}/${file}_1of2.zip":
     source  => "${mountPoint}/${file}_1of2.zip",
     require => File[$path],
   }

   # db file 2 installer zip
   file { "${path}/${file}_2of2.zip":
     source  => "${mountPoint}/${file}_2of2.zip",
     require => File["${path}/${file}_1of2.zip"],
   }

   exec { "extract ${path}/${file}_1of2.zip":
      command => "unzip -o ${path}/${file}_1of2.zip -d ${path}/${file}",
      require => File["${path}/${file}_1of2.zip"],
      creates => "${path}/${file}/database/install/addLangs.sh",
   }

   exec { "extract ${path}/${file}_2of2.zip":
      command => "unzip -o ${path}/${file}_2of2.zip -d ${path}/${file}",
      require => [ File["${path}/${file}_2of2.zip"], Exec["extract ${path}/${file}_1of2.zip"], ],
      creates => "${path}/${file}/database/stage/Components/oracle.rdbms/12.1.0.1.0/1/DataFiles/filegroup19.6.1.jar",
   }
 }



 if $version == '11.2.0.1' {  

   # db file 1 installer zip
   file { "${path}/${file}_1of2.zip":
     source  => "${mountPoint}/${file}_1of2.zip",
     require => File[$path],
   }


   exec { "extract ${path}/${file}_1of2.zip":
      command => "unzip -o ${path}/${file}_1of2.zip -d ${path}/${file}",
      require => File["${path}/${file}_1of2.zip"],
   }
       

   # db file 2 installer zip
   file { "${path}/${file}_2of2.zip":
     source  => "${mountPoint}/${file}_2of2.zip",
     require => File["${path}/${file}_1of2.zip"],
   }

   exec { "extract ${path}/${file}_2of2.zip":
      command => "unzip -o ${path}/${file}_2of2.zip -d ${path}/${file}",
      require => File["${path}/${file}_2of2.zip"],
   }
 }

 if ( $version == '11.2.0.3' or $version == '11.2.0.4' ) {  

   # db file 1 installer zip
   file { "${path}/${file}_1of7.zip":
     source  => "${mountPoint}/${file}_1of7.zip",
     require => File[$path],
   }


   exec { "extract ${path}/${file}_1of7.zip":
      command => "unzip -o ${path}/${file}_1of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_1of7.zip"],
   }
       

   # db file 2 installer zip
   file { "${path}/${file}_2of7.zip":
     source  => "${mountPoint}/${file}_2of7.zip",
     require => File["${path}/${file}_1of7.zip"],
   }

   exec { "extract ${path}/${file}_2of7.zip":
      command => "unzip -o ${path}/${file}_2of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_2of7.zip"],
   }
       

   # db file 3 installer zip
   file { "${path}/${file}_3of7.zip":
     source  => "${mountPoint}/${file}_3of7.zip",
     require => File["${path}/${file}_2of7.zip"],
   }

   exec { "extract ${path}/${file}_3of7.zip":
      command => "unzip -o ${path}/${file}_3of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_3of7.zip"],
   }
       


   # db file 4 installer zip
   file { "${path}/${file}_4of7.zip":
     source  => "${mountPoint}/${file}_4of7.zip",
     require => File["${path}/${file}_3of7.zip"],
   }

   exec { "extract ${path}/${file}_4of7.zip":
      command => "unzip -o ${path}/${file}_4of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_4of7.zip"],
   }
       

   # db file 5 installer zip
   file { "${path}/${file}_5of7.zip":
     source  => "${mountPoint}/${file}_5of7.zip",
     require => File["${path}/${file}_4of7.zip"],
   }

   exec { "extract ${path}/${file}_5of7.zip":
      command => "unzip -o ${path}/${file}_5of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_5of7.zip"],
   }
       


   # db file 6 installer zip
   file { "${path}/${file}_6of7.zip":
     source  => "${mountPoint}/${file}_6of7.zip",
     require => File["${path}/${file}_5of7.zip"],
   }

   exec { "extract ${path}/${file}_6of7.zip":
      command => "unzip -o ${path}/${file}_6of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_6of7.zip"],
   }
       

   # db file 7 installer zip
   file { "${path}/${file}_7of7.zip":
     source  => "${mountPoint}/${file}_7of7.zip",
     require => File["${path}/${file}_6of7.zip"],
   }
                                   
   exec { "extract ${path}/${file}_7of7.zip":
      command => "unzip -o ${path}/${file}_7of7.zip -d ${path}/${file}",
      require => File["${path}/${file}_7of7.zip"],
   }
 }

   if ! defined(File["${oraInstPath}/oraInst.loc"]) {
     file { "${oraInstPath}/oraInst.loc":
            ensure  => present,
            content => template("oradb/oraInst.loc.erb"),
          }
   }


   if ! defined(File[$oracleBase]) {
      # check oracle base folder
      file { $oracleBase :
        ensure  => directory,
        recurse => false, 
        replace => false,
      }
   }

   if ! defined(File["${path}/db_install_${version}.rsp"]) {
     file { "${path}/db_install_${version}.rsp":
            ensure  => present,
            content => template("oradb/db_install_${version}.rsp.erb"),
            require => File["${oraInstPath}/oraInst.loc"],
          }
   }

   if $version == '12.1.0.1' {     
     exec { "install oracle database ${title}":
            command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -responseFile ${path}/db_install_${version}.rsp'",
            require     => [File ["${oraInstPath}/oraInst.loc"],File["${path}/db_install_${version}.rsp"],Exec["extract ${path}/${file}_2of2.zip"]],
            creates     => $oracleHome,
     } 
   }

   if ( $version == '11.2.0.3' or $version == '11.2.0.4' ) {     
     exec { "install oracle database ${title}":
            command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -responseFile ${path}/db_install_${version}.rsp'",
            require     => [File ["${oraInstPath}/oraInst.loc"],File["${path}/db_install_${version}.rsp"],Exec["extract ${path}/${file}_7of7.zip"]],
            creates     => $oracleHome,
     } 
   }

   if $version == '11.2.0.1' {     
     exec { "install oracle database ${title}":
            command     => "/bin/sh -c 'unset DISPLAY;${path}/${file}/database/runInstaller -silent -waitforcompletion -responseFile ${path}/db_install_${version}.rsp'",
            require     => [File ["${oraInstPath}/oraInst.loc"],File["${path}/db_install_${version}.rsp"],Exec["extract ${path}/${file}_2of2.zip"]],
            creates     => $oracleHome,
     } 
   }
   
   

   if ! defined(File["/home/${user}/.bash_profile"]) {
     file { "/home/${user}/.bash_profile":
            ensure  => present,
            content => template("oradb/bash_profile.erb"),
          }
   }

   exec { "run root.sh script ${title}":
          command   => "${oracleHome}/root.sh",
          user      => 'root',
          group     => 'root',
          require   => Exec["install oracle database ${title}"],          
   }    

}

}

