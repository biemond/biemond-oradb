# Oracle Database puppet module
[![Build Status](https://travis-ci.org/biemond/biemond-oradb.png)](https://travis-ci.org/biemond/biemond-oradb)

created by Edwin Biemond
[biemond.blogspot.com](http://biemond.blogspot.com)
[Github homepage](https://github.com/biemond/puppet)

Should work on Docker, for Solaris and on all Linux version like RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux
- Docker image of Oracle Database 12.1 SE [Docker Oracle Database 12.1.0.1](https://github.com/biemond/docker-database-puppet)
- CentOS 6.5 vagrant box with Oracle Database 12.1 and Enterprise Manager 12.1.0.4 [Enterprise vagrant box](https://github.com/biemond/biemond-em-12c)
- Solaris 11.2 vagrant box with Oracle Database 12.1 [solaris 11.2 vagrant box](https://github.com/biemond/biemond-oradb-vagrant-12.1-solaris11.2)
- Solaris 10 vagrant box with Oracle Database 12.1 [solaris 10 vagrant box](https://github.com/biemond/biemond-orawls-vagrant-solaris-soa)
- CentOS 6.5 vagrant box with Oracle Database 11.2.0.4 and GoldenGate 12.1.2 [coherence goldengate vagrant box]( https://github.com/biemond/vagrant-wls12.1.2-coherence-goldengate)

Example of Opensource Puppet 3.4.3 Puppet master configuration in a vagrant box [puppet master](https://github.com/biemond/vagrant-puppetmaster)
- oradb (oracle database 11.2.0.1 ) with GoldenGate 12.1.2

Should work for Puppet 2.7 & 3.0

## Oracle Database Features

- Oracle Grid 11.2.0.4, 12.1.0.1 Linux / Solaris installation
- Oracle Database 12.1.0.1,12.1.0.2 Linux / Solaris installation
- Oracle Database 11.2.0.1,11.2.0.3,11.2.0.4 Linux / Solaris installation
- Oracle Database Instance 11.2 & 12.1 or provide your own db template
- Oracle Database Client 12.1.0.1,12.1.0.2,11.2.0.4,11.2.0.1 Linux / Solaris installation
- Oracle Database Net configuration
- Oracle Database Listener
- Tnsnames entry
- Oracle ASM
- Oracle RAC
- OPatch upgrade
- Apply OPatch also for Clusterware
- Create database instances
- Stop/Start database instances with db_control puppet resource type

## Enterprise Manager
- Enterprise Manager Server 12.1.0.4 12c cloud installation / configuration
- Agent installation via AgentPull.sh & AgentDeploy.sh

## GoldenGate
- GoldenGate 12.1.2, 11.2.1

## Repository Creation Utility (RCU)
- Installs RCU repositoy for Oracle SOA Suite / Webcenter ( 11.1.1.6.0 and 11.1.1.7.0 ) / Oracle Identity Management ( 11.1.2.1 )

## Oracle RAC
In combination with the [ora_rac](https://forge.puppetlabs.com/hajee/ora_rac) module of Bert Hajee (https://forge.puppetlabs.com/hajee/ora_rac)

## Oracle Database resource types
- db_control, start stop or a restart a database instance also used by dbactions manifest.pp
- db_opatch, used by the opatch.pp manifest
- db_rcu, used by the rcu.pp manifest


In combination with the [oracle](http://forge.puppetlabs.com/hajee/oracle) module of Bert Hajee (http://forge.puppetlabs.com/hajee/oracle) you can also create
- create a tablespace
- create a user with the required grants and quota's
- create one or more roles
- create one or more services
- change a database init parameter (Memory or SPFILE)


Some manifests like installdb.pp, opatch.pp or rcusoa.pp supports an alternative mountpoint for the big oracle files.
When not provided it uses the files location of the oradb puppet module
else you can use $puppetDownloadMntPoint => "/mnt" or "puppet:///modules/xxxx/"

## Oracle Big files and alternate download location
Some manifests like oradb:installdb, opatch or rcu supports an alternative mountpoint for the big oracle setup/install files.
When not provided it uses the files folder located in the orawls puppet module
else you can use $source =>
- "/mnt"
- "/vagrant"
- "puppet:///modules/oradb/" (default)
- "puppet:///database/"

when the files are also locally accessible then you can also set $remote_file => false this will not move the files to the download folder, just extract or install

## templates.pp

The databaseType value should contain only one of these choices.
- EE = Enterprise Edition
- SE = Standard Edition
- SEONE = Standard Edition One

## Installation, Disk or memory issues

    # hiera
    hosts:
      'emdb.example.com':
        ip:                "10.10.10.15"
        host_aliases:      'emdb'
      'localhost':
        ip:                "127.0.0.1"
        host_aliases:      'localhost.localdomain,localhost4,localhost4.localdomain4'

    $host_instances = hiera('hosts', {})
    create_resources('host',$host_instances)

    # disable the firewall
    service { iptables:
      enable    => false,
      ensure    => false,
      hasstatus => true,
    }

    # set the swap ,forge puppet module petems-swap_file
    class { 'swap_file':
      swapfile     => '/var/swap.1',
      swapfilesize => '8192000000'
    }

    # set the tmpfs
    mount { '/dev/shm':
      ensure      => present,
      atboot      => true,
      device      => 'tmpfs',
      fstype      => 'tmpfs',
      options     => 'size=3500m',
    }

see this chapter "Linux kernel, ulimits and required packages" for more important information

## Database install

    $puppetDownloadMntPoint = "puppet:///modules/oradb/"

    oradb::installdb{ '12.1.0.2_Linux-x86-64':
      version                => '12.1.0.2',
      file                   => 'V46095-01',
      databaseType           => 'SE',
      oracleBase             => '/oracle',
      oracleHome             => '/oracle/product/12.1/db',
      createUser             => true,
      bashProfile            => true,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      group_oper             => 'oper',
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
      bashProfile            => true,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      group_oper             => 'oper',
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
      eeOptionsSelection     => true,
      eeOptionalComponents   => 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0',
      createUser             => true,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      group_oper             => 'oper',
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
      group_install          => 'oinstall',
      group_oper             => 'oper',
      downloadDir            => '/install',
      zipExtract             => true,
      puppetDownloadMntPoint => $puppetDownloadMntPoint,
    }

or

    oradb::installdb{ '112010_Linux-x86-64':
      version       => '11.2.0.1',
      file          => 'linux.x64_11gR2_database',
      databaseType  => 'SE',
      oracleBase    => '/oracle',
      oracleHome    => '/oracle/product/11.2/db',
      createUser    => true,
      user          => 'oracle',
      group         => 'dba',
      group_install => 'oinstall',
      group_oper    => 'oper',
      downloadDir   => '/install',
      zipExtract    => true,
     }

Patching

For opatchupgrade you need to provide the Oracle support csiNumber and supportId and need to be online. Or leave them empty but it needs the Expect rpm to emulate OCM

    oradb::opatchupgrade{'112000_opatch_upgrade':
      oracleHome             => '/oracle/product/11.2/db',
      patchFile              => 'p6880880_112000_Linux-x86-64.zip',
      #  csiNumber              => '11111',
      #  supportId              => 'biemond@gmail.com',
      csiNumber              => undef,
      supportId              => undef,
      opversion              => '11.2.0.3.6',
      user                   => 'oracle',
      group                  => 'dba',
      downloadDir            => '/install',
      puppetDownloadMntPoint => $puppetDownloadMntPoint,
      require                =>  Oradb::Installdb['112030_Linux-x86-64'],
    }

Opatch

    # for this example OPatch 14727310
    # the OPatch utility must be upgraded ( patch 6880880, see above)
    oradb::opatch{'14727310_db_patch':
      ensure                 => 'present',
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

or for clusterware (GRID)

    oradb::opatch{'18706472_grid_patch':
      ensure                 => 'present',
      oracleProductHome      => hiera('grid_home_dir'),
      patchId                => '18706472',
      patchFile              => 'p18706472_112040_Linux-x86-64.zip',
      clusterWare            => true,
      bundleSubPatchId       => '18522515',
      user                   => hiera('grid_os_user'),
      group                  => 'oinstall',
      downloadDir            => hiera('oracle_download_dir'),
      ocmrf                  => true,
      require                => Oradb::Opatchupgrade['112000_opatch_upgrade'],
      puppetDownloadMntPoint => hiera('oracle_source'),
    }

Oracle net

    oradb::net{ 'config net8':
      oracleHome   => '/oracle/product/11.2/db',
      version      => '11.2' or "12.1",
      user         => 'oracle',
      group        => 'dba',
      downloadDir  => '/install',
      dbPort       => '1521', #optional
      require      => Oradb::Opatch['14727310_db_patch'],
    }

Listener

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

Database instance

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
      dbPort                  => '1521', #optional
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
      emConfiguration         => "NONE",
      require                 => Oradb::Listener['start listener'],
    }

or based on your own template

Add your template to the template dir of the oradb module, the template must be have the following extension dbtemplate.dbt.erb
Click here for an [12.1 db instance template example](https://github.com/biemond/biemond-oradb/blob/master/templates/dbtemplate.dbt.erb)

    oradb::database{ 'testDb_Create':
      oracleBase              => '/oracle',
      oracleHome              => '/oracle/product/12.1/db',
      version                 => '12.1',
      user                    => 'oracle',
      group                   => 'dba',
      template                => 'dbtemplate', #  this will use dbtemplate.dbt.erb example template
      downloadDir             => '/install',
      action                  => 'create',
      dbName                  => 'test',
      dbDomain                => 'oracle.com',
      dbPort                  => '1521',
      sysPassword             => 'Welcome01',
      systemPassword          => 'Welcome01',
      dataFileDestination     => "/oracle/oradata",
      recoveryAreaDestination => "/oracle/flash_recovery_area",
      characterSet            => "AL32UTF8",
      nationalCharacterSet    => "UTF8",
      memoryPercentage        => "40",
      memoryTotal             => "800",
      require                 => Oradb::Listener['start listener'],
    }

or delete a database

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


Database instance actions

    db_control{'emrepos start':
      ensure                  => 'running', #running|start|abort|stop
      instance_name           => 'test',
      oracle_product_home_dir => '/oracle/product/11.2/db',
      os_user                 => 'oracle',
    }

    db_control{'emrepos stop':
      ensure                  => 'stop', #running|start|abort|stop
      instance_name           => 'test',
      oracle_product_home_dir => '/oracle/product/11.2/db',
      os_user                 => 'oracle',
    }

    # the old way
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

    # subscribe to changes
    db_control{'emrepos restart':
      ensure                  => 'running', #running|start|abort|stop
      instance_name           => 'test',
      oracle_product_home_dir => '/oracle/product/11.2/db',
      os_user                 => 'oracle',
      refreshonly             => true,
      subscribe               => Init_param['emrepos/memory_target'],
    }

    oradb::autostartdatabase{ 'autostart oracle':
      oracleHome              => '/oracle/product/12.1/db',
      user                    => 'oracle',
      dbName                  => 'test',
      require                 => Oradb::Dbactions['start testDb'],
    }

Tnsnames.ora

    oradb::tnsnames{'orcl':
      oracleHome         => '/oracle/product/11.2/db',
      user               => 'oracle',
      group              => 'dba',
      server             => { myserver => { host => soadb.example.nl, port => '1521', protocol => 'TCP' }},
      connectServiceName => 'soarepos.example.nl',
      require            => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'test':
      oracleHome         => '/oracle/product/11.2/db',
      user               => 'oracle',
      group              => 'dba',
      server             => { myserver => { host => soadb.example.nl, port => '1525', protocol => 'TCP' }, { host => soadb2.example.nl, port => '1526', protocol => 'TCP' }},
      connectServiceName => 'soarepos.example.nl',
      connectServer      => 'DEDICATED',
      require            => Oradb::Dbactions['start oraDb'],
    }


## Grid install with ASM

      $all_groups = ['oinstall','dba' ,'oper','asmdba','asmadmin','asmoper']

      group { $all_groups :
        ensure      => present,
      }

      user { 'oracle' :
        ensure      => present,
        uid         => 500,
        gid         => 'oinstall',
        groups      => ['oinstall','dba','oper','asmdba'],
        shell       => '/bin/bash',
        password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
        home        => "/home/oracle",
        comment     => "This user oracle was created by Puppet",
        require     => Group[$all_groups],
        managehome  => true,
      }

      user { 'grid' :
        ensure      => present,
        uid         => 501,
        gid         => 'oinstall',
        groups      => ['oinstall','dba','asmadmin','asmdba','asmoper'],
        shell       => '/bin/bash',
        password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
        home        => "/home/grid",
        comment     => "This user grid was created by Puppet",
        require     => Group[$all_groups],
        managehome  => true,
      }

      ####### NFS example

      file { '/nfs_server_data':
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => 'grid',
        group   => 'asmadmin',
        require =>  User['grid'],
      }

      class { 'nfs::server':
        package => latest,
        service => running,
        enable  => true,
      }

      nfs::export { '/nfs_server_data':
        options => [ 'rw', 'sync', 'no_wdelay','insecure_locks','no_root_squash' ],
        clients => [ "*" ],
        require => File['/nfs_server_data']
      }

      file { '/nfs_client':
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => 'grid',
        group   => 'asmadmin',
        require =>  User['grid'],
      }

      mounts { 'Mount point for NFS data':
        ensure => present,
        source => 'soadbasm:/nfs_server_data',
        dest   => '/nfs_client',
        type   => 'nfs',
        opts   => 'rw,bg,hard,nointr,tcp,vers=3,timeo=600,rsize=32768,wsize=32768,actimeo=0  0 0',
      }

      exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520":
        user      => 'grid',
        group     => 'asmadmin',
        logoutput => true,
        unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b1",
        require   => Mounts['Mount point for NFS data'],
      }
      exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520":
        user      => 'grid',
        group     => 'asmadmin',
        logoutput => true,
        unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b2",
        require   => [Mounts['Mount point for NFS data'],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"]],
      }

      exec { "/bin/chown grid:asmadmin /nfs_client/*":
        user      => 'root',
        group     => 'root',
        logoutput => true,
        require   => Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],
      }
      exec { "/bin/chmod 664 /nfs_client/*":
        user      => 'root',
        group     => 'root',
        logoutput => true,
        require   => Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],
      }
      ###### end of NFS example


      // oradb::installasm{ '12.1_linux-x64':
      //  version                => '12.1.0.1',
      //  file                   => 'linuxamd64_12c_grid',

      oradb::installasm{ '11.2_linux-x64':
        version                => '11.2.0.4',
        file                   => 'p13390677_112040_Linux-x86-64_3of7.zip',
        gridType               => 'HA_CONFIG',
        gridBase               => hiera('grid_base_dir'),
        gridHome               => hiera('grid_home_dir'),
        oraInventoryDir        => hiera('oraInventory_dir'),
        userBaseDir            => '/home',
        user                   => hiera('grid_os_user'),
        group                  => 'asmdba',
        group_install          => 'oinstall',
        group_oper             => 'asmoper',
        group_asm              => 'asmadmin',
        sys_asm_password       => 'Welcome01',
        asm_monitor_password   => 'Welcome01',
        asm_diskgroup          => 'DATA',
        disk_discovery_string  => "/nfs_client/asm*",
        disks                  => "/nfs_client/asm_sda_nfs_b1,/nfs_client/asm_sda_nfs_b2",
        # disk_discovery_string  => "ORCL:*",
        # disks                  => "ORCL:DISK1,ORCL:DISK2",
        disk_redundancy        => "EXTERNAL",
        downloadDir            => hiera('oracle_download_dir'),
        remoteFile             => false,
        puppetDownloadMntPoint => hiera('oracle_source'),
      }

      oradb::opatchupgrade{'112000_opatch_upgrade_asm':
          oracleHome             => hiera('grid_home_dir'),
          patchFile              => 'p6880880_112000_Linux-x86-64.zip',
          # csiNumber              => '172409',
          # supportId              => 'biemond@gmail.com',
          csiNumber              => undef,
          supportId              => undef,
          opversion              => '11.2.0.3.6',
          user                   => hiera('grid_os_user'),
          group                  => 'oinstall',
          downloadDir            => hiera('oracle_download_dir'),
          puppetDownloadMntPoint => hiera('oracle_source'),
          require                => Oradb::Installasm['db_linux-x64'],
      }

      oradb::opatch{'18706472_grid_patch':
        ensure                 => 'present',
        oracleProductHome      => hiera('grid_home_dir'),
        patchId                => '18706472',
        patchFile              => 'p18706472_112040_Linux-x86-64.zip',
        clusterWare            => true,
        bundleSubPatchId       => '18522515',
        user                   => hiera('grid_os_user'),
        group                  => 'oinstall',
        downloadDir            => hiera('oracle_download_dir'),
        ocmrf                  => true,
        require                => Oradb::Opatchupgrade['112000_opatch_upgrade_asm'],
        puppetDownloadMntPoint => hiera('oracle_source'),
      }

      oradb::installdb{ '11.2_linux-x64':
        version                => '11.2.0.4',
        file                   => 'p13390677_112040_Linux-x86-64',
        databaseType           => 'EE',
        oraInventoryDir        => hiera('oraInventory_dir'),
        oracleBase             => hiera('oracle_base_dir'),
        oracleHome             => hiera('oracle_home_dir'),
        userBaseDir            => '/home',
        createUser             => false,
        user                   => hiera('oracle_os_user'),
        group                  => 'dba',
        group_install          => 'oinstall',
        group_oper             => 'oper',
        downloadDir            => hiera('oracle_download_dir'),
        remoteFile             => false,
        puppetDownloadMntPoint => hiera('oracle_source'),
        require                => Oradb::Opatch['18706472_grid_patch'],
      }

      oradb::database{ 'oraDb':
        oracleBase              => hiera('oracle_base_dir'),
        oracleHome              => hiera('oracle_home_dir'),
        version                 => '11.2',
        user                    => hiera('oracle_os_user'),
        group                   => hiera('oracle_os_group'),
        downloadDir             => hiera('oracle_download_dir'),
        action                  => 'create',
        dbName                  => hiera('oracle_database_name'),
        dbDomain                => hiera('oracle_database_domain_name'),
        sysPassword             => hiera('oracle_database_sys_password'),
        systemPassword          => hiera('oracle_database_system_password'),
        characterSet            => "AL32UTF8",
        nationalCharacterSet    => "UTF8",
        initParams              => "open_cursors=1000,processes=600,job_queue_processes=4",
        sampleSchema            => 'FALSE',
        memoryPercentage        => "40",
        memoryTotal             => "800",
        databaseType            => "MULTIPURPOSE",
        storageType             => "ASM",
        asmSnmpPassword         => 'Welcome01',
        asmDiskgroup            => 'DATA',
        recoveryDiskgroup       => undef,
        recoveryAreaDestination => 'DATA',
        require                 => Oradb::Installdb['11.2_linux-x64'],
      }

## Oracle Database Client

    oradb::client{ '12.1.0.1_Linux-x86-64':
      version                => '12.1.0.1',
      file                   => 'linuxamd64_12c_client.zip',
      oracleBase             => '/oracle',
      oracleHome             => '/oracle/product/12.1/client',
      createUser             => true,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      downloadDir            => '/install',
      remoteFile             => true,
      puppetDownloadMntPoint => "puppet:///modules/oradb/",
      logoutput               => true,
    }

or

    oradb::client{ '11.2.0.1_Linux-x86-64':
      version                => '11.2.0.1',
      file                   => 'linux.x64_11gR2_client.zip',
      oracleBase             => '/oracle',
      oracleHome             => '/oracle/product/11.2/client',
      createUser             => true,
      user                   => 'oracle',
      group                  => 'dba',
      group_install          => 'oinstall',
      downloadDir            => '/install',
      remoteFile             => false,
      puppetDownloadMntPoint => "/software",
      logoutput              => true,
    }

## Enteprise Mananager

    oradb::installem{ 'em12104':
      version                     => '12.1.0.4',
      file                        => 'em12104_linux64',
      oracle_base_dir             => '/oracle',
      oracle_home_dir             => '/oracle/product/12.1/em',
      agent_base_dir              => '/oracle/product/12.1/agent',
      software_library_dir        => '/oracle/product/12.1/swlib',
      weblogic_user               => 'weblogic',
      weblogic_password           => 'Welcome01',
      database_hostname           => 'emdb.example.com',
      database_listener_port      => 1521,
      database_service_sid_name   => 'emrepos.example.com',
      database_sys_password       => 'Welcome01',
      sysman_password             => 'Welcome01',
      agent_registration_password => 'Welcome01',
      deployment_size             => 'SMALL',
      user                        => 'oracle',
      group                       => 'oinstall',
      download_dir                => '/install',
      zip_extract                 => true,
      puppet_download_mnt_point   => '/software',
      remote_file                 => false,
      log_output                  => true,
    }

    oradb::installem_agent{ 'em12104_agent':
      version                     => '12.1.0.4',
      source                      => 'https://10.10.10.25:7802/em/install/getAgentImage',
      install_type                => 'agentPull',
      install_platform            => 'Linux x86-64',
      oracle_base_dir             => '/oracle',
      agent_base_dir              => '/oracle/product/12.1/agent',
      agent_instance_home_dir     => '/oracle/product/12.1/agent/agent_inst',
      sysman_user                 => 'sysman',
      sysman_password             => 'Welcome01',
      agent_registration_password => 'Welcome01',
      agent_port                  => 1830,
      oms_host                    => '10.10.10.25',
      oms_port                    => 7802,
      em_upload_port              => 4903,
      user                        => 'oracle',
      group                       => 'dba',
      download_dir                => '/var/tmp/install',
      log_output                  => true,
    }

    oradb::installem_agent{ 'em12104_agent2':
      version                     => '12.1.0.4',
      source                      => '/var/tmp/install/agent.zip',
      install_type                => 'agentDeploy',
      oracle_base_dir             => '/oracle',
      agent_base_dir              => '/oracle/product/12.1/agent2',
      agent_instance_home_dir     => '/oracle/product/12.1/agent2/agent_inst',
      agent_registration_password => 'Welcome01',
      agent_port                  => 1832,
      oms_host                    => '10.10.10.25',
      em_upload_port              => 4903,
      user                        => 'oracle',
      group                       => 'dba',
      download_dir                => '/var/tmp/install',
      log_output                  => true,
    }

## Database configuration
In combination with the oracle puppet module from hajee you can create/change a database init parameter, tablespace,role or an oracle user

    init_param { 'SPFILE/OPEN_CURSORS:emrepos':
      ensure => 'present',
      value  => '600',
    }

    init_param { 'SPFILE/processes:emrepos':
      ensure => 'present',
      value  => '1000',
    }

    init_param{'SPFILE/job_queue_processes:emrepos':
      ensure  => present,
      value   => '20',
    }

    init_param{'SPFILE/session_cached_cursors:emrepos':
      ensure  => present,
      value   => '200',
    }

    init_param{'SPFILE/db_securefile:emrepos':
      ensure  => present,
      value   => 'PERMITTED',
    }

    init_param{'SPFILE/memory_target:emrepos':
      ensure  => present,
      value   => '3000M',
    }

    init_param { 'SPFILE/PGA_AGGREGATE_TARGET:emrepos':
      ensure => 'present',
      value  => '1G',
      require => Init_param['SPFILE/memory_target:emrepos'],
    }

    init_param { 'SPFILE/SGA_TARGET:emrepos':
      ensure => 'present',
      value  => '1200M',
      require => Init_param['SPFILE/memory_target:emrepos'],
    }
    init_param { 'SPFILE/SHARED_POOL_SIZE:emrepos':
      ensure => 'present',
      value  => '600M',
      require => Init_param['SPFILE/memory_target:emrepos'],
    }

    db_control{'emrepos restart':
      ensure                  => 'running', #running|start|abort|stop
      instance_name           => hiera('oracle_database_name'),
      oracle_product_home_dir => hiera('oracle_home_dir'),
      os_user                 => hiera('oracle_os_user'),
      refreshonly             => true,
      subscribe               => [Init_param['SPFILE/OPEN_CURSORS:emrepos'],
                                  Init_param['SPFILE/processes:emrepos'],
                                  Init_param['SPFILE/job_queue_processes:emrepos'],
                                  Init_param['SPFILE/session_cached_cursors:emrepos'],
                                  Init_param['SPFILE/db_securefile:emrepos'],
                                  Init_param['SPFILE/SGA_TARGET:emrepos'],
                                  Init_param['SPFILE/SHARED_POOL_SIZE:emrepos'],
                                  Init_param['SPFILE/PGA_AGGREGATE_TARGET:emrepos'],
                                  Init_param['SPFILE/memory_target:emrepos'],],
    }


    tablespace {'scott_ts':
      ensure                    => present,
      size                      => 100M,
      datafile                  => 'scott_ts.dbf',
      logging                   => yes,
      autoextend                => on,
      next                      => 100M,
      max_size                  => 12288M,
      extent_management         => local,
      segment_space_management  => auto,
    }

    role {'apps':
      ensure    => present,
    }

    oracle_user{'scott':
      temporary_tablespace      => temp,
      default_tablespace        => 'scott_ts',
      password                  => 'tiger',
      grants                    => ['SELECT ANY TABLE',
                                    'CONNECT',
                                    'RESOURCE',
                                    'apps'],
      quotas                    => { "scott_ts" => 'unlimited'},
      require                   => [Tablespace['scott_ts'],
                                    Role['apps']],
    }

    init_param{'sid/parameter/instance':
      ensure  => present,
      value   => 'the_value'
    }

## Oracle GoldenGate 12.1.2 and 11.2.1


      $groups = ['oinstall','dba']

      group { $groups :
        ensure      => present,
        before      => User['ggate'],
      }

      user { 'ggate' :
        ensure      => present,
        gid         => 'dba',
        groups      => $groups,
        shell       => '/bin/bash',
        password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
        home        => "/home/ggate",
        comment     => "This user ggate was created by Puppet",
        managehome  => true,
      }

      file { "/oracle/product" :
        ensure        => directory,
        recurse       => false,
        replace       => false,
        mode          => 0775,
        group         => hiera('oracle_os_group'),
      }

      oradb::goldengate{ 'ggate12.1.2':
        version                 => '12.1.2',
        file                    => '121200_fbo_ggs_Linux_x64_shiphome.zip',
        databaseType            => 'Oracle',
        databaseVersion         => 'ORA11g',
        databaseHome            => '/oracle/product/11.2/db',
        oracleBase              => '/oracle',
        goldengateHome          => "/oracle/product/12.1.2/ggate",
        managerPort             => 16000,
        user                    => 'ggate',
        group                   => 'dba',
        group_install           => 'oinstall',
        downloadDir             => '/install',
        puppetDownloadMntPoint  => hiera('oracle_source'),
        require                 => File["/oracle/product"],
      }

      file { "/oracle/product/12.1.2/ggate/OPatch" :
        ensure        => directory,
        recurse       => true,
        replace       => false,
        mode          => 0775,
        group         => hiera('oracle_os_group'),
        require       => Oradb::Goldengate['ggate12.1.2'],
      }

      file { "/oracle/product/11.2.1" :
        ensure        => directory,
        recurse       => false,
        replace       => false,
        mode          => 0775,
        owner         => 'ggate',
        group         => hiera('oracle_os_group'),
      }

      oradb::goldengate{ 'ggate11.2.1':
        version                 => '11.2.1',
        file                    => 'ogg112101_fbo_ggs_Linux_x64_ora11g_64bit.zip',
        tarFile                 => 'fbo_ggs_Linux_x64_ora11g_64bit.tar',
        goldengateHome          => "/oracle/product/11.2.1/ggate",
        user                    => hiera('ggate_os_user'),
        group                   => hiera('oracle_os_group'),
        downloadDir             => '/install',
        puppetDownloadMntPoint  =>  hiera('oracle_source'),
        require                 => [File["/oracle/product"],File["/oracle/product/11.2.1"]]
      }

      oradb::goldengate{ 'ggate11.2.1_java':
        version                 => '11.2.1',
        file                    => 'V38714-01.zip',
        tarFile                 => 'ggs_Adapters_Linux_x64.tar',
        goldengateHome          => "/oracle/product/11.2.1/ggate_java",
        user                    => hiera('ggate_os_user'),
        group                   => hiera('oracle_os_group'),
        group_install           => 'oinstall',
        downloadDir             => '/install',
        puppetDownloadMntPoint  =>  hiera('oracle_source'),
        require                 => [File["/oracle/product"],File["/oracle/product/11.2.1"]]
      }

## Oracle SOA Suite Repository Creation Utility (RCU)

product =
- soasuite
- webcenter
- all

RCU examples

soa suite repository

    oradb::rcu{'DEV_PS6':
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

    oradb::rcu{'DEV2_PS6':
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

    oradb::rcu{'Delete_DEV3_PS5':
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

    oradb::rcu{'DEV_1112':
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


## Linux kernel, ulimits and required packages

install the following module to set the database kernel parameters
*puppet module install fiddyspence-sysctl*

install the following module to set the database user limits parameters
*puppet module install erwbgy-limits*

      group { 'dba' :
        ensure      => present,
      }

      user { 'oracle' :
        ensure      => present,
        gid         => 'dba',
        groups      => 'dba',
        shell       => '/bin/bash',
        password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
        home        => "/home/oracle",
        comment     => "This user oracle was created by Puppet",
        require     => Group['dba'],
        managehome  => true,
      }

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
                    'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext.x86_64','libXtst.x86_64']

      package { $install:
        ensure  => present,
      }

## Solaris 10 kernel, ulimits and required packages

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


    $all_groups = ['oinstall','dba' ,'oper']

    group { $all_groups :
      ensure      => present,
    }

    user { 'oracle' :
      ensure      => present,
      uid         => 500,
      gid         => 'oinstall',
      groups      => ['oinstall','dba','oper'],
      shell       => '/bin/bash',
      password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
      home        => "/home/oracle",
      comment     => "This user oracle was created by Puppet",
      require     => Group[$all_groups],
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

## Solaris 11 kernel, ulimits and required packages

    package { ['shell/ksh', 'developer/assembler']:
      ensure => present,
    }

    $install  = "pkg:/group/prerequisite/oracle/oracle-rdbms-server-12-1-preinstall"

    package { $install:
      ensure  => present,
    }

    $groups = ['oinstall','dba' ,'oper' ]

    group { $groups :
      ensure      => present,
    }

    user { 'oracle' :
      ensure      => present,
      uid         => 500,
      gid         => 'dba',
      groups      => $groups,
      shell       => '/bin/bash',
      password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
      home        => "/export/home/oracle",
      comment     => "This user oracle was created by Puppet",
      require     => Group[$groups],
      managehome  => true,
    }

    $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

    exec { "projadd group.dba":
      command => "projadd -U oracle -G dba -p 104 group.dba",
      require => User["oracle"],
      unless  => "projects -l | grep -c group.dba",
      path    => $execPath,
    }

    exec { "usermod oracle":
      command => "usermod -K project=group.dba oracle",
      require => [User["oracle"],Exec["projadd group.dba"],],
      path    => $execPath,
    }

    exec { "projmod max-shm-memory":
      command => "projmod -sK 'project.max-shm-memory=(privileged,4G,deny)' group.dba",
      require => [User["oracle"],Exec["projadd group.dba"],],
      path    => $execPath,
    }

    exec { "projmod max-sem-ids":
      command     => "projmod -sK 'project.max-sem-ids=(privileged,100,deny)' group.dba",
      require     => Exec["projadd group.dba"],
      path        => $execPath,
    }

    exec { "projmod max-shm-ids":
      command     => "projmod -s -K 'project.max-shm-ids=(privileged,100,deny)' group.dba",
      require     => Exec["projadd group.dba"],
      path        => $execPath,
    }

    exec { "projmod max-sem-nsems":
      command     => "projmod -sK 'process.max-sem-nsems=(privileged,256,deny)' group.dba",
      require     => Exec["projadd group.dba"],
      path        => $execPath,
    }

    exec { "projmod max-file-descriptor":
      command     => "projmod -sK 'process.max-file-descriptor=(basic,65536,deny)' group.dba",
      require     => Exec["projadd group.dba"],
      path        => $execPath,
    }

    exec { "projmod max-stack-size":
      command     => "projmod -sK 'process.max-stack-size=(privileged,32MB,deny)' group.dba",
      require     => Exec["projadd group.dba"],
      path        => $execPath,
    }

    exec { "ipadm smallest_anon_port tcp":
      command     => "ipadm set-prop -p smallest_anon_port=9000 tcp",
      path        => $execPath,
    }
    exec { "ipadm smallest_anon_port udp":
      command     => "ipadm set-prop -p smallest_anon_port=9000 udp",
      path        => $execPath,
    }
    exec { "ipadm largest_anon_port tcp":
      command     => "ipadm set-prop -p largest_anon_port=65500 tcp",
      path        => $execPath,
    }
    exec { "ipadm largest_anon_port udp":
      command     => "ipadm set-prop -p largest_anon_port=65500 udp",
      path        => $execPath,
    }

    exec { "ulimit -S":
      command => "ulimit -S -n 4096",
      path    => $execPath,
    }

    exec { "ulimit -H":
      command => "ulimit -H -n 65536",
      path    => $execPath,
    }