Oracle Database Linux puppet module
=================================================

created by Edwin Biemond
[biemond.blogspot.com](http://biemond.blogspot.com)
[Github homepage](https://github.com/biemond/puppet)

Should work for Solaris and all Linux version like RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux

Here you can test the solaris 10 vagrant box with Oracle Database 12.1  
https://github.com/biemond/biemond-orawls-vagrant-solaris-soa


Works with Puppet 2.7 & 3.0

Version updates
---------------

- 0.9.5 RCU fixes for OIM,OAM
- 0.9.0 Solaris Support,Own DB facts, no conflict with orawls or wls
- 0.8.9 RCU allows existing Temp tablespace
- 0.8.7 Readme update
- 0.8.6 RCU OIM option for Oracle Identity Management
- 0.8.5 timeout = 0 and added -ignoreSysPrereqs -ignorePrereq on installdb
- 0.8.4 updated license to Apache 2.0
- 0.8.3 support for extracted oracle software (shared storage) with zipExtract , RCU product value "all"    
- 0.8.2 OPatch upgrade fix for Offline, option to skip to create user and group    
- 0.8.1 Removed sleep and replaced by waitforcompletion
- 0.8.0 Autostart bugfixes and support for oracle 11.2.0.4  database
- 0.7.9 Autostart of listener and database with chkconfig / init.d
- 0.7.8 Added Suse SLES as Operating System
- 0.7.7 RCU support for WebCenter and SOA Suite
- 0.7.6 OPatch upgrade made by Ronald Hatcher
- 0.7.5 support for Oracle database 12c or 12.1.0.1 plus bug fixes
- 0.7.4 puppet 3.0 compatible
- 0.7.3 bugfixes plus facts in sync with wls modules
- 0.7.2 bugfixes for rcu and database facts


Oracle Database Features
---------------------------

- Oracle Database 12.1.0.1 Linux / Solaris installation
- Oracle Database 11.2.0.4 Linux / Solaris installation
- Oracle Database 11.2.0.3 Linux / Solaris installation
- Oracle Database 11.2.0.1 Linux / Solaris installation
- Oracle Database Net configuration
- Oracle Database Listener
- OPatch upgrade
- Apply OPatch
- Create database instances
- Stop/Start database instances
- Installs RCU repositoy for Oracle SOA Suite / Webcenter ( 11.1.1.6.0 and 11.1.1.7.0 ) / Oracle Identity Management ( 11.1.2.1 )

Some manifests like installdb.pp, opatch.pp or rcusoa.pp supports an alternative mountpoint for the big oracle files.
When not provided it uses the files location of the oradb puppet module
else you can use $puppetDownloadMntPoint => "/mnt" or "puppet:///modules/xxxx/"

Oracle Big files and alternate download location
------------------------------------------------
Some manifests like oradb:installdb, opatch or rcu supports an alternative mountpoint for the big oracle setup/install files.  
When not provided it uses the files folder located in the orawls puppet module  
else you can use $source =>
- "/mnt"
- "/vagrant"
- "puppet:///modules/oradb/" (default)
- "puppet:///database/"  

when the files are also accesiable locally then you can also set $remote_file => false this will not move the files to the download folder, just extract or install 



Files
-----
- 11.2.0.1 Download oracle database linux software from http://otn.oracle.com
- 11.2.0.3 Download oracle database linux software from http://support.oracle.com
- Patch 10404530: 11.2.0.3.0 PATCH SET FOR ORACLE DATABASE SERVER
- 11.2.0.4 Download oracle database linux software from http://support.oracle.com
- 12.1.0.1 Download oracle database linux software from http://otn.oracle.com

upload these files to the files folder of the oradb puppet module


# database files of linux 12.1.0.1 ( otn.oracle.com )
- 1361028723 Jun 27 23:38 linuxamd64_12c_database_1of2.zip
- 1116527103 Jun 27 23:38 linuxamd64_12c_database_2of2.zip

# database files of linux 11.2.0.3 ( support.oracle.com )
- 1358454646 Mar  9 17:31 p10404530_112030_Linux-x86-64_1of7.zip
- 1142195302 Mar  9 17:47 p10404530_112030_Linux-x86-64_2of7.zip
-  979195792 Mar  9 18:01 p10404530_112030_Linux-x86-64_3of7.zip
-  659229728 Mar  9 18:11 p10404530_112030_Linux-x86-64_4of7.zip
-  616473105 Mar  9 18:19 p10404530_112030_Linux-x86-64_5of7.zip
-  479890040 Mar  9 18:26 p10404530_112030_Linux-x86-64_6of7.zip
-  113915106 Mar  9 18:28 p10404530_112030_Linux-x86-64_7of7.zip

# database files of linux 11.2.0.4 ( support.oracle.com )
- 1395582860 Aug 31 16:21 p13390677_112040_Linux-x86-64_1of7.zip
- 1151304589 Aug 31 16:22 p13390677_112040_Linux-x86-64_2of7.zip
- 1205251894 Aug 31 16:22 p13390677_112040_Linux-x86-64_3of7.zip
-  656026876 Aug 31 16:22 p13390677_112040_Linux-x86-64_4of7.zip
-  599170344 Aug 31 16:23 p13390677_112040_Linux-x86-64_5of7.zip
-  488372844 Aug 31 16:23 p13390677_112040_Linux-x86-64_6of7.zip
-  119521122 Aug 31 16:23 p13390677_112040_Linux-x86-64_7of7.zip

# database files of linux 11.2.0.1 ( otn.oracle.com )
- 1239269270 Mar 10 17:05 linux.x64_11gR2_database_1of2.zip
- 1111416131 Mar 10 17:17 linux.x64_11gR2_database_2of2.zip

# opatch database patch for 11.2.0.3
- 25556377 Mar 10 12:48 p14727310_112030_Linux-x86-64.zip

# opatch upgrade
- 32551984 Jul  6 18:58 p6880880_112000_Linux-x86-64.zip

# database client linux 11.2.0.1 ( otn.oracle.com )
- 706187979 Mar 10 16:48 linux.x64_11gR2_client.zip

# rcu linux installer
- 408989041 Mar 17 20:17 ofm_rcu_linux_11.1.1.6.0_disk1_1of1.zip
- 411498103 Apr  1 21:23 ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip

important support node
[ID 1441282.1] Requirements for Installing Oracle 11gR2 RDBMS on RHEL6 or OL6 64-bit (x86-64)


Oracle Database Facter
-------------------
Contains Oracle Facter which displays the following
- Oracle Software
- Opatch patches

### Example of the Oracle Database Facts

    oradb_inst_loc_data /oracle/oraInventory
    oradb_inst_patches_oracle_product_11.2_db Patches;14727310;
    oradb_inst_products /oracle/product/11.2/db;

templates.pp
------------

The databaseType value should contain only one of these choices.
- EE = Enterprise Edition
- SE = Standard Edition
- SEONE = Standard Edition One

normal install

    $puppetDownloadMntPoint = "puppet:///modules/oradb/"
    
    oradb::installdb{ '12.1.0.1_Linux-x86-64':
            version                => '12.1.0.1',
            file                   => 'linuxamd64_12c_database',
            databaseType           => 'SE',
            oracleBase             => '/oracle',
            oracleHome             => '/oracle/product/12.1/db',
            createUser             => true,
            user                   => 'oracle',
            group                  => 'dba',
            downloadDir            => '/data/install',
            zipExtract             => true,
            puppetDownloadMntPoint => $puppetDownloadMntPoint,
    }

or with zipExtract ( does not download or extract , software is in /install/linuxamd64_12c_database )  

    oradb::installdb{ '12.1.0.1_Linux-x86-64':
            version                => '12.1.0.1',
            file                   => 'linuxamd64_12c_database',
            databaseType           => 'SE',
            oracleBase             => '/oracle',
            oracleHome             => '/oracle/product/12.1/db',
            user                   => 'oracle',
            group                  => 'dba',
            createUser             => true,
            downloadDir            => '/install',
            zipExtract             => false,
    }

or

    oradb::installdb{ '112040_Linux-x86-64':
            version                => '11.2.0.4',
            file                   => 'p13390677_112040_Linux-x86-64',
            databaseType           => 'SE',
            oracleBase             => '/oracle',
            oracleHome             => '/oracle/product/11.2/db',
            createUser             => true,
            user                   => 'oracle',
            group                  => 'dba',
            downloadDir            => '/install',
            zipExtract             => true,
            puppetDownloadMntPoint => $puppetDownloadMntPoint,
    }

or

     oradb::installdb{ '112030_Linux-x86-64':
            version                => '11.2.0.3',
            file                   => 'p10404530_112030_Linux-x86-64',
            databaseType           => 'SE',
            oracleBase             => '/oracle',
            oracleHome             => '/oracle/product/11.2/db',
            createUser             => true,
            user                   => 'oracle',
            group                  => 'dba',
            downloadDir            => '/install',
            zipExtract             => true,
            puppetDownloadMntPoint => $puppetDownloadMntPoint,
     }

or

    oradb::installdb{ '112010_Linux-x86-64':
            version      => '11.2.0.1',
            file         => 'linux.x64_11gR2_database',
            databaseType => 'SE',
            oracleBase   => '/oracle',
            oracleHome   => '/oracle/product/11.2/db',
            createUser   => true,
            user         => 'oracle',
            group        => 'dba',
            downloadDir  => '/install',
            zipExtract   => true,
     }

other

    oradb::opatchupgrade{'112000_opatch_upgrade':
        oracleHome             => '/oracle/product/11.2/db',
        patchFile              => 'p6880880_112000_Linux-x86-64.zip',
        csiNumber              => '11111',
        supportId              => 'biemond@gmail.com',
        opversion              => '11.2.0.3.4',
        user                   => 'oracle',
        group                  => 'dba',
        downloadDir            => '/install',
        puppetDownloadMntPoint => $puppetDownloadMntPoint,
        require                =>  Oradb::Installdb['112030_Linux-x86-64'],
    }
    
    # for this example OPatch 14727310
    # the OPatch utility must be upgraded ( patch 6880880, see above)
    oradb::opatch{'14727310_db_patch':
       oracleProductHome      => '/oracle/product/11.2/db',
       patchId                => '14727310',
       patchFile              => 'p14727310_112030_Linux-x86-64.zip',
       user                   => 'oracle',
       group                  => 'dba',
       downloadDir            => '/install',
       ocmrf                  => true,
       require                => Oradb::Opatchupgrade['112000_opatch_upgrade'],
       puppetDownloadMntPoint => $puppetDownloadMntPoint,
    }
    
    oradb::net{ 'config net8':
            oracleHome   => '/oracle/product/11.2/db',
            version      => '11.2' or "12.1",
            user         => 'oracle',
            group        => 'dba',
            downloadDir  => '/install',
            require      => Oradb::Opatch['14727310_db_patch'],
    }
    
    oradb::listener{'stop listener':
            oracleBase   => '/oracle',
            oracleHome   => '/oracle/product/11.2/db',
            user         => 'oracle',
            group        => 'dba',
            action       => 'start',
            require      => Oradb::Net['config net8'],
    }
    
    oradb::listener{'start listener':
            oracleBase   => '/oracle',
            oracleHome   => '/oracle/product/11.2/db',
            user         => 'oracle',
            group        => 'dba',
            action       => 'start',
            require      => Oradb::Listener['stop listener'],
    }
    
    oradb::database{ 'testDb_Create':
                      oracleBase              => '/oracle',
                      oracleHome              => '/oracle/product/11.2/db',
                      version                 => '11.2' or "12.1",
                      user                    => 'oracle',
                      group                   => 'dba',
                      downloadDir             => '/install',
                      action                  => 'create',
                      dbName                  => 'test',
                      dbDomain                => 'oracle.com',
                      sysPassword             => 'Welcome01',
                      systemPassword          => 'Welcome01',
                      dataFileDestination     => "/oracle/oradata",
                      recoveryAreaDestination => "/oracle/flash_recovery_area",
                      characterSet            => "AL32UTF8",
                      nationalCharacterSet    => "UTF8",
                      initParams              => "open_cursors=1000,processes=600,job_queue_processes=4",
                      sampleSchema            => 'TRUE',
                      memoryPercentage        => "40",
                      memoryTotal             => "800",
                      databaseType            => "MULTIPURPOSE",
                      require                 => Oradb::Listener['start listener'],
    }
    
    oradb::dbactions{ 'stop testDb':
                     oracleHome              => '/oracle/product/11.2/db',
                     user                    => 'oracle',
                     group                   => 'dba',
                     action                  => 'stop',
                     dbName                  => 'test',
                     require                 => Oradb::Database['testDb'],
    }
    
    oradb::dbactions{ 'start testDb':
                     oracleHome              => '/oracle/product/11.2/db',
                     user                    => 'oracle',
                     group                   => 'dba',
                     action                  => 'start',
                     dbName                  => 'test',
                     require                 => Oradb::Dbactions['stop testDb'],
    }
    
    oradb::autostartdatabase{ 'autostart oracle':
                     oracleHome              => '/oracle/product/12.1/db',
                     user                    => 'oracle',
                     dbName                  => 'test',
                     require                 => Oradb::Dbactions['start testDb'],
    }
    
    oradb::database{ 'testDb_Delete':
                      oracleBase              => '/oracle',
                      oracleHome              => '/oracle/product/11.2/db',
                      user                    => 'oracle',
                      group                   => 'dba',
                      downloadDir             => '/install',
                      action                  => 'delete',
                      dbName                  => 'test',
                      sysPassword             => 'Welcome01',
                      require                 => Oradb::Dbactions['start testDb'],
    }
    
    case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian: {
        $mtimeParam = "1"
      }
      Solaris: {
        $mtimeParam = "+1"
      }
    }
    
    case $operatingsystem {
      CentOS, RedHat, OracleLinux, Ubuntu, Debian, Solaris: {
        cron { 'oracle_db_opatch':
          command => "find /oracle/product/12.1/db/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_db_purge.log 2>&1",
          user    => oracle,
          hour    => 06,
          minute  => 34,
        }
        
        cron { 'oracle_db_lsinv':
          command => "find /oracle/product/12.1/db/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_db_purge.log 2>&1",
          user    => oracle,
          hour    => 06,
          minute  => 32,
        }
      }
    }

Oracle SOA Suite Repository Creation Utility (RCU)  

product =
- soasuite
- webcenter
- all

RCU examples

soa suite repository

    oradb::rcu{     'DEV_PS6':
                     rcuFile          => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
                     product          => 'soasuite',
                     version          => '11.1.1.7',
                     oracleHome       => '/oracle/product/11.2/db',
                     user             => 'oracle',
                     group            => 'dba',
                     downloadDir      => '/install',
                     action           => 'create',
                     dbServer         => 'dbagent1.alfa.local:1521',
                     dbService        => 'test.oracle.com',
                     sysPassword      => 'Welcome01',
                     schemaPrefix     => 'DEV',
                     reposPassword    => 'Welcome02',
    }

webcenter repository with a fixed temp tablespace

    oradb::rcu{     'DEV2_PS6':
                     rcuFile          => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
                     product          => 'webcenter',
                     version          => '11.1.1.7',
                     oracleHome       => '/oracle/product/11.2/db',
                     user             => 'oracle',
                     group            => 'dba',
                     downloadDir      => '/install',
                     action           => 'create',
                     dbServer         => 'dbagent1.alfa.local:1521',
                     dbService        => 'test.oracle.com',
                     sysPassword      => 'Welcome01',
                     schemaPrefix     => 'DEV',
                     tempTablespace   => 'TEMP',
                     reposPassword    => 'Welcome02',
    }

delete a repository

    oradb::rcu{     'Delete_DEV3_PS5':
                     rcuFile          => 'ofm_rcu_linux_11.1.1.6.0_disk1_1of1.zip',
                     product          => 'soasuite',
                     version          => '11.1.1.6',
                     oracleHome       => '/oracle/product/11.2/db',
                     user             => 'oracle',
                     group            => 'dba',
                     downloadDir      => '/install',
                     action           => 'delete',
                     dbServer         => 'dbagent1.alfa.local:1521',
                     dbService        => 'test.oracle.com',
                     sysPassword      => 'Welcome01',
                     schemaPrefix     => 'DEV3',
                     reposPassword    => 'Welcome02',
    }

OIM, OAM repository, OIM needs an Oracle Enterprise Edition database

    oradb::rcu{ 'DEV_1112':
                     rcuFile                => 'V37476-01.zip',
                     product                => 'oim',
                     version                => '11.1.2.1',  
                     oracleHome             => '/oracle/product/11.2/db',
                     user                   => 'oracle',
                     group                  => 'dba',
                     downloadDir            => '/data/install',
                     action                 => 'create',
                     dbServer               => 'oimdb.alfa.local:1521',  
                     dbService              => 'oim.oracle.com',
                     sysPassword            => hiera('database_test_sys_password'),
                     schemaPrefix           => 'DEV',
                     reposPassword          => hiera('database_test_rcu_dev_password'),
                     puppetDownloadMntPoint => $puppetDownloadMntPoint,
                     logoutput              => true, 
                     require                => Oradb::Dbactions['start oimDb'],
     }


Linux kernel, ulimits and required packages
-------------------------------------------

install the following module to set the database kernel parameters
*puppet module install fiddyspence-sysctl*

install the following module to set the database user limits parameters
*puppet module install erwbgy-limits*


     node database {
       sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
       sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
       sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
       sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
       sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
       sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
       sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
       sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
       sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
       sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
       sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
       sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
       sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
       sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
       sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
       sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
       sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}
      
      
       class { 'limits':
         config => {
                    '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                    'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                    'nproc'  => { soft => '2048'   , hard => '16384',  },
                                    'stack'  => { soft => '10240'  ,},},
                    },
         use_hiera => false,
       }
       
       $install = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
                    'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64',
                    'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
                    'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.i686','libXtst.i686']
       
       package { $install:
         ensure  => present,
       }
     
     }
     
     node 'dbagent1.alfa.local' inherits database {
     }


Solaris 10 kernel, ulimits and required packages
------------------------------------------------

    exec { "create /cdrom/unnamed_cdrom":
      command => "/usr/bin/mkdir -p /cdrom/unnamed_cdrom",
      creates => "/cdrom/unnamed_cdrom",
    }
    
    mount { "/cdrom/unnamed_cdrom":
      device   => "/dev/dsk/c0t1d0s2",
      fstype   => "hsfs",
      ensure   => "mounted",
      options  => "ro",
      atboot   => true,
      remounts => false,
      require  => Exec["create /cdrom/unnamed_cdrom"],
    }
    
    $install = [ 
                 'SUNWarc','SUNWbtool','SUNWcsl',
                 'SUNWdtrc','SUNWeu8os','SUNWhea',
                 'SUNWi1cs', 'SUNWi15cs',
                 'SUNWlibC','SUNWlibm','SUNWlibms',
                 'SUNWsprot','SUNWpool','SUNWpoolr',
                 'SUNWtoo','SUNWxwfnt'
                ]
                 
    package { $install:
      ensure    => present,
      adminfile => "/vagrant/pkgadd_response",
      source    => "/cdrom/unnamed_cdrom/Solaris_10/Product/",
      require   => [Exec["create /cdrom/unnamed_cdrom"],
                    Mount["/cdrom/unnamed_cdrom"]
                   ],  
    }
    package { 'SUNWi1of':
      ensure    => present,
      adminfile => "/vagrant/pkgadd_response",
      source    => "/cdrom/unnamed_cdrom/Solaris_10/Product/",
      require   => Package[$install],  
    }
    
    
    # pkginfo -i SUNWarc SUNWbtool SUNWhea SUNWlibC SUNWlibm SUNWlibms SUNWsprot SUNWtoo SUNWi1of SUNWi1cs SUNWi15cs SUNWxwfnt SUNWcsl SUNWdtrc
    # pkgadd -d /cdrom/unnamed_cdrom/Solaris_10/Product/ -r response -a response SUNWarc SUNWbtool SUNWhea SUNWlibC SUNWlibm SUNWlibms SUNWsprot SUNWtoo SUNWi1of SUNWi1cs SUNWi15cs SUNWxwfnt SUNWcsl SUNWdtrc
    
    exec { "remove localhost":
      command => "/usr/bin/sed -e '/'127.0.0.1'/ d' /etc/hosts > /tmp/hosts.tmp && mv /tmp/hosts.tmp /etc/hosts",
      unless  => "/usr/bin/grep -c ${hostname} /etc/hosts",
    }
    
    exec { "add localhost":
      command => "/bin/echo '127.0.0.1 localhost ${fqdn} ${hostname}' >>/etc/hosts",
      unless  => "/usr/bin/grep -c ${hostname} /etc/hosts",
      require => Exec["remove localhost"],
    }
  
    group { 'dba' :
      ensure      => present,
    }
  
    user { 'oracle' :
      ensure      => present,
      gid         => 'dba',  
      groups      => 'dba',
      shell       => '/bin/bash',
      password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
      home        => "/export/home/oracle",
      comment     => "This user ${user} was created by Puppet",
      require     => Group['dba'],
      managehome  => true,
    }
  
    $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"
  
    exec { "projadd max-shm-memory":
      command => "projadd -p 102  -c 'ORADB' -U oracle -G dba  -K 'project.max-shm-memory=(privileged,4G,deny)' ORADB",
      require => [ User["oracle"],
                   Package['SUNWi1of'],
                   Package[$install],
                 ],
      unless  => "projects -l | grep -c ORADB",           
      path    => $execPath,
    }
  
    exec { "projmod max-sem-ids":
      command     => "projmod -s -K 'project.max-sem-ids=(privileged,100,deny)' ORADB",
      subscribe   => Exec["projadd max-shm-memory"],
      require     => Exec["projadd max-shm-memory"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "projmod max-shm-ids":
      command     => "projmod -s -K 'project.max-shm-ids=(privileged,100,deny)' ORADB",
      require     => Exec["projmod max-sem-ids"],
      subscribe   => Exec["projmod max-sem-ids"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "projmod max-sem-nsems":
      command     => "projmod -s -K 'process.max-sem-nsems=(privileged,256,deny)' ORADB",
      require     => Exec["projmod max-shm-ids"],
      subscribe   => Exec["projmod max-shm-ids"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "projmod max-file-descriptor":
      command     => "projmod -s -K 'process.max-file-descriptor=(basic,65536,deny)' ORADB",
      require     => Exec["projmod max-sem-nsems"],
      subscribe   => Exec["projmod max-sem-nsems"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "projmod max-stack-size":
      command     => "projmod -s -K 'process.max-stack-size=(privileged,32MB,deny)' ORADB",
      require     => Exec["projmod max-file-descriptor"],
      subscribe   => Exec["projmod max-file-descriptor"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "usermod oracle":
      command     => "usermod -K project=ORADB oracle",
      require     => Exec["projmod max-stack-size"],
      subscribe   => Exec["projmod max-stack-size"],
      refreshonly => true, 
      path        => $execPath,
    }
  
    exec { "ndd 1":
      command => "ndd -set /dev/tcp tcp_smallest_anon_port 9000",
      require => Exec["usermod oracle"],
      path    => $execPath,
    }
    exec { "ndd 2":
      command => "ndd -set /dev/tcp tcp_largest_anon_port 65500",
      require => Exec["ndd 1"],
      path    => $execPath,
    }
  
    exec { "ndd 3":
      command => "ndd -set /dev/udp udp_smallest_anon_port 9000",
      require => Exec["ndd 2"],
      path    => $execPath,
    }
  
    exec { "ndd 4":
      command => "ndd -set /dev/udp udp_largest_anon_port 65500",
      require => Exec["ndd 3"],
      path    => $execPath,
    }    
  
    exec { "ulimit -S":
      command => "ulimit -S -n 4096",
      require => Exec["ndd 4"],
      path    => $execPath,
    }
  
    exec { "ulimit -H":
      command => "ulimit -H -n 65536",
      require => Exec["ulimit -S"],
      path    => $execPath,
    }  
  
  