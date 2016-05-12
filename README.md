# Oracle Database puppet module
[![Build Status](https://travis-ci.org/biemond/biemond-oradb.png)](https://travis-ci.org/biemond/biemond-oradb) [![Coverage Status](https://coveralls.io/repos/biemond/biemond-oradb/badge.png?branch=master)](https://coveralls.io/r/biemond/biemond-oradb?branch=master)

This version located at [puppet4_3_data branch](https://github.com/biemond/biemond-oradb/tree/puppet4_3_data) uses the latest features of puppet 4 like
- Strong data typing
- Internal hiera module data

It cannot be used with puppet 3

created by Edwin Biemond
[biemond.blogspot.com](http://biemond.blogspot.com)
[Github homepage](https://github.com/biemond/puppet)

If you need support, checkout the [ora_install](https://www.enterprisemodules.com/shop/products/puppet-ora_install-module) from [Enterprise Modules](https://www.enterprisemodules.com/)

[![Enterprise Modules](https://raw.githubusercontent.com/enterprisemodules/public_images/master/banner1.jpg)](https://www.enterprisemodules.com)

With version >= 2.0.0  all manifest parameters are in lowercase and in snakestyle instead of camelcase

Dependency with
- puppetlabs/concat >= 1.0.0
- puppetlabs/stdlib >= 4.0.0

Should work on Docker, for Solaris and on all Linux version like RedHat, CentOS, Ubuntu, Debian, Suse SLES or OracleLinux
- Docker image of Oracle Database 12.1 SE [Docker Oracle Database 12.1.0.1](https://github.com/biemond/docker-database-puppet)
- CentOS 6.5 vagrant box with Oracle Database 12.1 and Enterprise Manager 12.1.0.4 [Enterprise vagrant box](https://github.com/biemond/biemond-em-12c)
- CentOS 6.6 vagrant box with Oracle Database 12.1.0.2 on NFS ASM [ASM vagrant box](https://github.com/biemond/biemond-oradb-vagrant-12.1-ASM)
- CentOS 6.6 vagrant box with Oracle Database 11.2.0.4 on NFS ASM [ASM vagrant box](https://github.com/biemond/biemond-oradb-vagrant-11.2-ASM)
- CentOS 6.6 vagrant box with Oracle Database 12.1.0.1 with pluggable databases [12c pluggable db vagrant box](https://github.com/biemond/biemond-oradb-vagrant-12.1-CDB)
- Solaris 11.2 vagrant box with Oracle Database 12.1 [solaris 11.2 vagrant box](https://github.com/biemond/biemond-oradb-vagrant-12.1-solaris11.2)
- Solaris 10 vagrant box with Oracle Database 12.1 [solaris 10 vagrant box](https://github.com/biemond/biemond-orawls-vagrant-solaris-soa)
- CentOS 6.5 vagrant box with Oracle Database 11.2.0.4 and GoldenGate 12.1.2 [coherence goldengate vagrant box]( https://github.com/biemond/vagrant-wls12.1.2-coherence-goldengate)

Example of Opensource Puppet 3.4.3 Puppet master configuration in a vagrant box [puppet master](https://github.com/biemond/vagrant-puppetmaster)
- oradb (oracle database 11.2.0.1 ) with GoldenGate 12.1.2

Should work for Puppet >=  4.0

## Oracle Database Features

- Oracle Grid 11.2.0.4, 12.1.0.1 Linux / Solaris installation
- Oracle Database 12.1.0.1,12.1.0.2 Linux / Solaris installation
- Oracle Database 11.2.0.1,11.2.0.3,11.2.0.4 Linux / Solaris installation
- Oracle Database Instance 11.2 & 12.1 with pluggable database or provide your own db template
- Oracle Database Client 12.1.0.1,12.1.0.2,11.2.0.4,11.2.0.1 Linux / Solaris installation
- Oracle Database Net configuration
- Oracle Database Listener
- Tnsnames entry
- Listener entry in tnsnames.ora
- Oracle ASM
- Oracle RAC
- OPatch upgrade
- Apply OPatch also for clusterware
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
- db_listener, start stop or a restart the oracle listener ( supports refreshonly )


In combination with the [oracle](http://forge.puppetlabs.com/hajee/oracle) module of Bert Hajee (http://forge.puppetlabs.com/hajee/oracle) you can also create
- create a tablespace
- create a user with the required grants and quota's
- create one or more roles
- create one or more services
- change a database init parameter (Memory or SPFILE)


Some manifests like installdb.pp, opatch.pp or rcusoa.pp supports an alternative mountpoint for the big oracle files.
When not provided it uses the files location of the oradb puppet module
else you can use $puppet_download_mnt_point => "/mnt" or "puppet:///modules/xxxx/"

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

The database_type value should contain only one of these choices.
- EE = Enterprise Edition
- SE = Standard Edition
- SEONE = Standard Edition One

##

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

## Linux kernel, ulimits and required packages

install the following module to set the database kernel parameters
*puppet module install fiddyspence-sysctl*

install the following module to set the database user limits parameters
*puppet module install erwbgy-limits*

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


## Database install

    $puppet_download_mnt_point = "puppet:///modules/oradb/"

    oradb::installdb{ '12.1.0.2_Linux-x86-64':
      version                   => '12.1.0.2',
      file                      => 'V46095-01',
      database_type             => 'SE',
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/12.1/db',
      bash_profile              => true,
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => '/data/install',
      zip_extract               => true,
      puppet_download_mnt_point => $puppet_download_mnt_point,
    }

or with zip_extract ( does not download or extract , software is in /install/linuxamd64_12c_database )

    oradb::installdb{ '12.1.0.1_Linux-x86-64':
      version                 => '12.1.0.1',
      file                    => 'linuxamd64_12c_database',
      database_type           => 'SE',
      oracle_base             => '/oracle',
      oracle_home             => '/oracle/product/12.1/db',
      bash_profile            => true,
      user                    => 'oracle',
      group                   => 'dba',
      group_install           => 'oinstall',
      group_oper              => 'oper',
      download_dir            => '/install',
      zip_extract             => false,
    }

or

    oradb::installdb{ '112040_Linux-x86-64':
      version                   => '11.2.0.4',
      file                      => 'p13390677_112040_Linux-x86-64',
      database_type             => 'SE',
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/11.2/db',
      ee_options_selection      => true,
      ee_optional_components    => 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0',
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => '/install',
      zip_extract               => true,
      puppet_download_mnt_point => $puppet_download_mnt_point,
    }

or

    oradb::installdb{ '112030_Linux-x86-64':
      version                   => '11.2.0.3',
      file                      => 'p10404530_112030_Linux-x86-64',
      database_type             => 'SE',
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/11.2/db',
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      group_oper                => 'oper',
      download_dir              => '/install',
      zip_extract               => true,
      puppet_download_mnt_point => $puppet_download_mnt_point,
    }

or

    oradb::installdb{ '112010_Linux-x86-64':
      version       => '11.2.0.1',
      file          => 'linux.x64_11gR2_database',
      database_type => 'SE',
      oracle_base   => '/oracle',
      oracle_home   => '/oracle/product/11.2/db',
      user          => 'oracle',
      group         => 'dba',
      group_install => 'oinstall',
      group_oper    => 'oper',
      download_dir  => '/install',
      zip_extract   => true,
     }

Patching

For opatchupgrade you need to provide the Oracle support csi_number and supportId and need to be online. Or leave them empty but it needs the Expect rpm to emulate OCM

    # use this on a Grid or Database home
    oradb::opatchupgrade{'112000_opatch_upgrade':
      oracle_home               => '/oracle/product/11.2/db',
      patch_file                => 'p6880880_112000_Linux-x86-64.zip',
      #  csi_number             => '11111',
      #  support_id             => 'biemond@gmail.com',
      csi_number                => undef,
      support_id                => undef,
      opversion                 => '11.2.0.3.6',
      user                      => 'oracle',
      group                     => 'dba',
      download_dir              => '/install',
      puppet_download_mnt_point => $puppet_download_mnt_point,
      require                   =>  Oradb::Installdb['112030_Linux-x86-64'],
    }

Opatch

    # october 2014 11.2.0.4.4 patch
    oradb::opatch{'19121551_db_patch':
      ensure                    => 'present',
      oracle_product_home       => hiera('oracle_home_dir'),
      patch_id                  => '19121551',
      patch_file                => 'p19121551_112040_Linux-x86-64.zip',
      user                      => hiera('oracle_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      require                   => Oradb::Opatchupgrade['112000_opatch_upgrade_db'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

or for clusterware aka opatch auto

to use the new opatchauto utility(12.1) instead of opatch auto(11.2) use this parameter use_opatchauto_utility => true

    oradb::opatch{'21523260_grid_patch':
      ensure                    => 'present',
      oracle_product_home       => hiera('grid_home_dir'),
      patch_id                  => '21523260',
      patch_file                => 'p21523260_121020_Linux-x86-64.zip',
      clusterware               => true,
      use_opatchauto_utility    => true,
      bundle_sub_patch_id       => '21359755', # sub patch_id of bundle patch ( else I can't detect it)
      user                      => hiera('grid_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      puppet_download_mnt_point => hiera('oracle_source'),
      require                   => Oradb::Opatchupgrade['121000_opatch_upgrade_asm'],
    }

the old way (11g)

    oradb::opatch{'18706472_grid_patch':
      ensure                    => 'present',
      oracle_product_home       => hiera('grid_home_dir'),
      patch_id                  => '18706472',
      patch_file                => 'p18706472_112040_Linux-x86-64.zip',
      clusterware               => true,
      bundle_sub_patch_id       => '18522515',  sub patch_id of bundle patch ( else I can't detect it if it is already applied)
      user                      => hiera('grid_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      require                   => Oradb::Opatchupgrade['112000_opatch_upgrade'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

    # this 19791420 patch contains 2 patches (in different sub folders), one bundle and a normal one.
    # we want to apply the bundle and need to provide the right value for bundle_sub_folder
    oradb::opatch{'19791420_grid_patch':
      ensure                    => 'present',
      oracle_product_home       => hiera('grid_home_dir'),
      patch_id                  => '19791420',
      patch_file                => 'p19791420_112040_Linux-x86-64.zip',
      clusterware               => true,
      bundle_sub_patch_id       => '19121552', # sub patch_id of bundle patch ( else I can't detect it if it is already applied)
      bundle_sub_folder         => '19380115', # optional subfolder inside the patch zip
      user                      => hiera('grid_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      require                   => Oradb::Opatchupgrade['112000_opatch_upgrade_asm'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

    # the same patch applied with opatch auto to an oracle database home, this time we need to use the 19121551 as bundle_sub_patch_id
    # this is the october 2014  11.2.0.4.4 patch
    oradb::opatch{'19791420_grid_patch':
      ensure                    => 'present',
      oracle_product_home       => hiera('oracle_home_dir'),
      patch_id                  => '19791420',
      patch_file                => 'p19791420_112040_Linux-x86-64.zip',
      clusterware               => true,
      bundle_sub_patch_id       => '19121551', # sub patch_id of bundle patch ( else I can't detect it if it is already applied)
      bundle_sub_folder         => '19380115', # optional subfolder inside the patch zip
      user                      => hiera('grid_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      require                   => Oradb::Opatchupgrade['112000_opatch_upgrade_asm'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

    # same patch 19791420 but then for the oracle db home, this patch requires the bundle patch of 19791420 or
    # 19121551 october 2014  11.2.0.4.4 patch
    oradb::opatch{'19791420_db_patch':
      ensure                     => 'present',
      oracle_product_home       => hiera('oracle_home_dir'),
      patch_id                  => '19791420',
      patch_file                => 'p19791420_112040_Linux-x86-64.zip',
      clusterware               => false,
      bundle_sub_patch_id       => '19282021', # sub patch_id of bundle patch ( else I can't detect it)
      bundle_sub_folder         => '19282021', # optional subfolder inside the patch zip
      user                      => hiera('oracle_os_user'),
      group                     => 'oinstall',
      download_dir              => hiera('oracle_download_dir'),
      ocmrf                     => true,
      require                   => Oradb::Opatch['19121551_db_patch'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

Oracle net

    oradb::net{ 'config net8':
      oracle_home   => '/oracle/product/11.2/db',
      version       => '11.2' or "12.1",
      user          => 'oracle',
      group         => 'dba',
      download_dir  => '/install',
      db_port       => '1521', #optional
      require       => Oradb::Opatch['14727310_db_patch'],
    }

Listener

    db_listener{ 'startlistener':
      ensure          => 'running',  # running|start|abort|stop
      oracle_base_dir => '/oracle',
      oracle_home_dir => '/oracle/product/11.2/db',
      os_user         => 'oracle',
      listener_name   => 'listener' # which is the default and optional
    }

    # subscribe to changes
    db_listener{ 'startlistener':
      ensure          => 'running',  # running|start|abort|stop
      oracle_base_dir => '/oracle',
      oracle_home_dir => '/oracle/product/11.2/db',
      os_user         => 'oracle',
      listener_name   => 'listener' # which is the default and optional
      refreshonly     => true,
      subscribe       => XXXXX,
    }

    # the old way which also calls db_listener type
    oradb::listener{'start listener':
      action        => 'start',  # running|start|abort|stop
      oracle_base   => '/oracle',
      oracle_home   => '/oracle/product/11.2/db',
      user          => 'oracle',
      group         => 'dba',
      listener_name => 'listener' # which is the default and optional
    }

Database instance

    oradb::database{ 'testDb_Create':
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/11.2/db',
      version                   => '11.2',
      user                      => 'oracle',
      group                     => 'dba',
      download_dir              => '/install',
      action                    => 'create',
      db_name                   => 'test',
      db_domain                 => 'oracle.com',
      db_port                   => '1521',
      sys_password              => 'Welcome01',
      system_password           => 'Welcome01',
      data_file_destination     => "/oracle/oradata",
      recovery_area_destination => "/oracle/flash_recovery_area",
      character_set             => "AL32UTF8",
      nationalcharacter_set     => "UTF8",
      init_params               => {'open_cursors'        => '1000',
                                    'processes'           => '600',
                                    'job_queue_processes' => '4' },
      sample_schema             => 'TRUE',
      memory_percentage         => "40",
      memory_total              => "800",
      database_type             => "MULTIPURPOSE",
      em_configuration          => "NONE",
      require                   => Oradb::Listener['start listener'],
    }

you can also use a comma separated string for init_params

      init_params              => "open_cursors=1000,processes=600,job_queue_processes=4",


or based on your own template

The template must be have the following extension dbt.erb like dbtemplate_12.1.dbt.erb, use puppet_download_mnt_point parameter for the template location or add your template to the template dir of the oradb module
- Click here for an [12.1 db instance template example](https://github.com/biemond/biemond-oradb/blob/master/templates/dbtemplate_12.1.dbt.erb)
- Click here for an [12.1 db asm instance template example](https://github.com/biemond/biemond-oradb/blob/master/templates/dbtemplate_12.1_asm.dbt.erb)
- Click here for an [11.2 db asm instance template example](https://github.com/biemond/biemond-oradb/blob/master/templates/dbtemplate_11gR2_asm.dbt.erb)

with a template of the oradb module

    oradb::database{ 'testDb_Create':
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/12.1/db',
      version                   => '12.1',
      user                      => 'oracle',
      group                     => 'dba',
      template                  => 'dbtemplate_12.1', # or dbtemplate_11gR2_asm, this will use dbtemplate_12.1.dbt.erb example template
      download_dir              => '/install',
      action                    => 'create',
      db_name                   => 'test',
      db_domain                 => 'oracle.com',
      db_port                   => '1521',
      sys_password              => 'Welcome01',
      system_password           => 'Welcome01',
      data_file_destination     => "/oracle/oradata",
      recovery_area_destination => "/oracle/flash_recovery_area",
      character_set             => "AL32UTF8",
      nationalcharacter_set     => "UTF8",
      memory_percentage         => "40",
      memory_total              => "800",
      require                   => Oradb::Listener['start listener'],
    }

or your own template on your own location

      template                   => 'my_dbtemplate_11gR2_asm',
      puppet_download_mnt_point  => '/vagrant', # 'oradb' etc


12c container and pluggable databases

    oradb::database{ 'oraDb':
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/12.1/db',
      version                   => '12.1',
      user                      => 'oracle',
      group                     => 'dba'
      download_dir              => '/install',
      action                    => 'create',
      db_name                   => 'orcl',
      db_domain                 => 'example.com',
      sys_password              => 'Welcome01',
      system_password           => 'Welcome01',
      character_set             => 'AL32UTF8',
      nationalcharacter_set     => 'UTF8',
      sample_schema             => 'FALSE',
      memory_percentage         => '40',
      memory_total              => '800',
      database_type             => 'MULTIPURPOSE',
      em_configuration          => 'NONE',
      data_file_destination     => '/oracle/oradata',
      recovery_area_destination => '/oracle/flash_recovery_area',
      init_params               => {'open_cursors'        => '1000',
                                    'processes'           => '600',
                                    'job_queue_processes' => '4' },
      container_database        => true,   <|-------
    }

    oradb::database_pluggable{'pdb1':
      ensure                   => 'present',
      version                  => '12.1',
      oracle_home_dir          => '/oracle/product/12.1/db',
      user                     => 'oracle',
      group                    => 'dba',
      source_db                => 'orcl',
      pdb_name                 => 'pdb1',
      pdb_admin_username       => 'pdb_adm',
      pdb_admin_password       => 'Welcome01',
      pdb_datafile_destination => "/oracle/oradata/orcl/pdb1",
      create_user_tablespace   => true,
      log_output               => true,
    }

    # remove the pluggable database
    oradb::database_pluggable{'pdb1':
      ensure                   => 'absent',
      version                  => '12.1',
      oracle_home_dir          => '/oracle/product/12.1/db',
      user                     => 'oracle',
      group                    => 'dba',
      source_db                => 'orcl',
      pdb_name                 => 'pdb1',
      pdb_datafile_destination => "/oracle/oradata/orcl/pdb1",
      log_output               => true,
    }

or delete a database

    oradb::database{ 'testDb_Delete':
      oracle_base             => '/oracle',
      oracle_home             => '/oracle/product/11.2/db',
      user                    => 'oracle',
      group                   => 'dba',
      download_dir            => '/install',
      action                  => 'delete',
      db_name                 => 'test',
      sys_password            => 'Welcome01',
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
      oracle_home             => '/oracle/product/11.2/db',
      user                    => 'oracle',
      group                   => 'dba',
      action                  => 'stop',
      db_name                 => 'test',
      require                 => Oradb::Database['testDb'],
    }

    oradb::dbactions{ 'start testDb':
      oracle_home             => '/oracle/product/11.2/db',
      user                    => 'oracle',
      group                   => 'dba',
      action                  => 'start',
      db_name                 => 'test',
      require                 => Oradb::Dbactions['stop testDb'],
    }

    # grid or asm
    db_control{'instance control asm':
      provider                => 'srvctl',
      ensure                  => 'start',
      instance_name           => '+ASM',
      oracle_product_home_dir => hiera('oracle_home_dir'),
      grid_product_home_dir   => hiera('grid_home_dir'),
      os_user                 => hiera('grid_os_user'),
      db_type                 => 'grid',
    }

    oradb::dbactions{ 'start grid':
      db_type                 => 'grid',
      oracle_home             => hiera('oracle_home_dir'),
      grid_home               => hiera('grid_home_dir'),
      user                    => hiera('grid_os_user'),
      group                   => hiera('oracle_os_group'),
      action                  => 'start',
      db_name                 => '+ASM',
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
      oracle_home             => '/oracle/product/12.1/db',
      user                    => 'oracle',
      db_name                 => 'test',
      require                 => Oradb::Dbactions['start testDb'],
    }


Tnsnames.ora

    oradb::tnsnames{'orcl':
      oracle_home          => '/oracle/product/11.2/db',
      user                 => 'oracle',
      group                => 'dba',
      server               => { myserver => { host => soadb.example.nl, port => '1521', protocol => 'TCP' }},
      connect_service_name => 'soarepos.example.nl',
      require              => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'test':
      oracle_home          => '/oracle/product/11.2/db',
      user                 => 'oracle',
      group                => 'dba',
      server               => { myserver => { host => soadb.example.nl, port => '1525', protocol => 'TCP' }, { host => soadb2.example.nl, port => '1526', protocol => 'TCP' }},
      connect_service_name => 'soarepos.example.nl',
      connect_server       => 'DEDICATED',
      require              => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'testlistener':
      entry_type         => 'listener',
      oracle_home        => '/oracle/product/11.2/db',
      user               => 'oracle',
      group              => 'dba',
      server             => { myserver => { host => 'soadb.example.nl', port => '1521', protocol => 'TCP' }},
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

      file { '/home/nfs_server_data':
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

      nfs::export { '/home/nfs_server_data':
        options => [ 'rw', 'sync', 'no_wdelay','insecure_locks','no_root_squash' ],
        clients => [ "*" ],
        require => [File['/home/nfs_server_data'],Class['nfs::server'],],
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
        ensure  => present,
        source  => 'soadbasm:/home/nfs_server_data',
        dest    => '/nfs_client',
        type    => 'nfs',
        opts    => 'rw,bg,hard,nointr,tcp,vers=3,timeo=600,rsize=32768,wsize=32768,actimeo=0  0 0',
        require => [File['/nfs_client'],Nfs::Export['/home/nfs_server_data'],]
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

      exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b3 bs=1M count=7520":
        user      => 'grid',
        group     => 'asmadmin',
        logoutput => true,
        unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b3",
        require   => [Mounts['Mount point for NFS data'],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],],
      }

      exec { "/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b4 bs=1M count=7520":
        user      => 'grid',
        group     => 'asmadmin',
        logoutput => true,
        unless    => "/usr/bin/test -f /nfs_client/asm_sda_nfs_b4",
        require   => [Mounts['Mount point for NFS data'],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b1 bs=1M count=7520"],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b2 bs=1M count=7520"],
                      Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b3 bs=1M count=7520"],],
      }

      $nfs_files = ['/nfs_client/asm_sda_nfs_b1','/nfs_client/asm_sda_nfs_b2','/nfs_client/asm_sda_nfs_b3','/nfs_client/asm_sda_nfs_b4']

      file { $nfs_files:
        ensure  => present,
        owner   => 'grid',
        group   => 'asmadmin',
        mode    => '0664',
        require => Exec["/bin/dd if=/dev/zero of=/nfs_client/asm_sda_nfs_b4 bs=1M count=7520"],
      }
      ###### end of NFS example


      oradb::installasm{ 'db_linux-x64':
        version                   => hiera('db_version'),
        file                      => hiera('asm_file'),
        grid_type                 => 'HA_CONFIG',
        grid_base                 => hiera('grid_base_dir'),
        grid_home                 => hiera('grid_home_dir'),
        ora_inventory_dir         => hiera('oraInventory_dir'),
        user_base_dir             => '/home',
        user                      => hiera('grid_os_user'),
        group                     => 'asmdba',
        group_install             => 'oinstall',
        group_oper                => 'asmoper',
        group_asm                 => 'asmadmin',
        sys_asm_password          => 'Welcome01',
        asm_monitor_password      => 'Welcome01',
        asm_diskgroup             => 'DATA',
        disk_discovery_string     => "/nfs_client/asm*",
        disks                     => "/nfs_client/asm_sda_nfs_b1,/nfs_client/asm_sda_nfs_b2",
        # disk_discovery_string   => "ORCL:*",
        # disks                   => "ORCL:DISK1,ORCL:DISK2",
        disk_redundancy           => "EXTERNAL",
        download_dir              => hiera('oracle_download_dir'),
        remote_file               => false,
        puppet_download_mnt_point => hiera('oracle_source'),
      }

      oradb::opatchupgrade{'112000_opatch_upgrade_asm':
        oracle_home               => hiera('grid_home_dir'),
        patch_file                => 'p6880880_112000_Linux-x86-64.zip',
        csi_number                => undef,
        support_id                => undef,
        opversion                 => '11.2.0.3.6',
        user                      => hiera('grid_os_user'),
        group                     => 'oinstall',
        download_dir              => hiera('oracle_download_dir'),
        puppet_download_mnt_point => hiera('oracle_source'),
        require                   => Oradb::Installasm['db_linux-x64'],
      }

      oradb::opatch{'19791420_grid_patch':
        ensure                    => 'present',
        oracle_product_home       => hiera('grid_home_dir'),
        patch_id                  => '19791420',
        patch_file                => 'p19791420_112040_Linux-x86-64.zip',
        clusterware               => true,
        bundle_sub_patch_id       => '19121552', # sub patch_id of bundle patch ( else I can't detect it)
        bundle_sub_folder         => '19380115', # optional subfolder inside the patch zip
        user                      => hiera('grid_os_user'),
        group                     => 'oinstall',
        download_dir              => hiera('oracle_download_dir'),
        ocmrf                     => true,
        require                   => Oradb::Opatchupgrade['112000_opatch_upgrade_asm'],
        puppet_download_mnt_point => hiera('oracle_source'),
      }

      oradb::installdb{ 'db_linux-x64':
        version                   => hiera('db_version'),
        file                      => hiera('db_file'),
        database_type             => 'EE',
        ora_inventory_dir         => hiera('oraInventory_dir'),
        oracle_base               => hiera('oracle_base_dir'),
        oracle_home               => hiera('oracle_home_dir'),
        user_base_dir             => '/home',
        user                      => hiera('oracle_os_user'),
        group                     => 'dba',
        group_install             => 'oinstall',
        group_oper                => 'oper',
        download_dir              => hiera('oracle_download_dir'),
        remote_file               => false,
        puppet_download_mnt_point => hiera('oracle_source'),
        # require                 => Oradb::Opatch['18706472_grid_patch'],
        require                   => Oradb::Opatch['19791420_grid_patch'],
      }

      oradb::opatchupgrade{'112000_opatch_upgrade_db':
        oracle_home               => hiera('oracle_home_dir'),
        patch_file                => 'p6880880_112000_Linux-x86-64.zip',
        csi_number                => undef,
        support_id                => undef,
        opversion                 => '11.2.0.3.6',
        user                      => hiera('oracle_os_user'),
        group                     => hiera('oracle_os_group'),
        download_dir              => hiera('oracle_download_dir'),
        puppet_download_mnt_point => hiera('oracle_source'),
        require                   => Oradb::Installdb['db_linux-x64'],
      }

      oradb::opatch{'19791420_db_patch':
        ensure                    => 'present',
        oracle_product_home       => hiera('oracle_home_dir'),
        patch_id                  => '19791420',
        patch_file                => 'p19791420_112040_Linux-x86-64.zip',
        clusterware               => true,
        bundle_sub_patch_id       => '19121551', #,'19121552', # sub patch_id of bundle patch ( else I can't detect it)
        bundle_sub_folder         => '19380115', # optional subfolder inside the patch zip
        user                      => hiera('oracle_os_user'),
        group                     => 'oinstall',
        download_dir              => hiera('oracle_download_dir'),
        ocmrf                     => true,
        require                   => Oradb::Opatchupgrade['112000_opatch_upgrade_db'],
        puppet_download_mnt_point => hiera('oracle_source'),
      }

      oradb::opatch{'19791420_db_patch_2':
        ensure                    => 'present',
        oracle_product_home       => hiera('oracle_home_dir'),
        patch_id                  => '19791420',
        patch_file                => 'p19791420_112040_Linux-x86-64.zip',
        clusterware               => false,
        bundle_sub_patch_id       => '19282021', # sub patch_id of bundle patch ( else I can't detect it)
        bundle_sub_folder         => '19282021', # optional subfolder inside the patch zip
        user                      => hiera('oracle_os_user'),
        group                     => 'oinstall',
        download_dir              => hiera('oracle_download_dir'),
        ocmrf                     => true,
        require                   => Oradb::Opatch['19791420_db_patch'],
        puppet_download_mnt_point => hiera('oracle_source'),
      }

      # with the help of the oracle and easy-type module of Bert Hajee
      ora_asm_diskgroup{ 'RECO@+ASM':
        ensure          => 'present',
        au_size         => '1',
        compat_asm      => '11.2.0.0.0',
        compat_rdbms    => '10.1.0.0.0',
        diskgroup_state => 'MOUNTED',
        disks           => {'RECO_0000' => {'diskname' => 'RECO_0000', 'path' => '/nfs_client/asm_sda_nfs_b3'},
                            'RECO_0001' => {'diskname' => 'RECO_0001', 'path' => '/nfs_client/asm_sda_nfs_b4'}},
        redundancy_type => 'EXTERNAL',
        require         => Oradb::Opatch['19791420_db_patch_2'],
      }

      # based on a template
      oradb::database{ 'oraDb':
        oracle_base               => hiera('oracle_base_dir'),
        oracle_home               => hiera('oracle_home_dir'),
        version                   => hiera('dbinstance_version'),
        user                      => hiera('oracle_os_user'),
        group                     => hiera('oracle_os_group'),
        download_dir              => hiera('oracle_download_dir'),
        action                    => 'create',
        db_name                   => hiera('oracle_database_name'),
        db_domain                 => hiera('oracle_database_domain_name'),
        sys_password              => hiera('oracle_database_sys_password'),
        system_password           => hiera('oracle_database_system_password'),
        template                  => 'dbtemplate_11gR2_asm',
        character_set             => "AL32UTF8",
        nationalcharacter_set     => "UTF8",
        sample_schema             => 'FALSE',
        memory_percentage         => "40",
        memory_total              => "800",
        database_type             => "MULTIPURPOSE",
        em_configuration          => "NONE",
        storage_type              => "ASM",
        asm_snmp_password         => 'Welcome01',
        asm_diskgroup             => 'DATA',
        recovery_diskgroup        => 'RECO',
        recovery_area_destination => 'RECO',
        require                   => [Oradb::Opatch['19791420_db_patch_2'],
                                      Ora_asm_diskgroup['RECO@+ASM'],],
      }

      # or not based on a template
      oradb::database{ 'oraDb':
        oracle_base               => hiera('oracle_base_dir'),
        oracle_home               => hiera('oracle_home_dir'),
        version                   => hiera('dbinstance_version'),
        user                      => hiera('oracle_os_user'),
        group                     => hiera('oracle_os_group'),
        download_dir              => hiera('oracle_download_dir'),
        action                    => 'create',
        db_name                   => hiera('oracle_database_name'),
        db_domain                 => hiera('oracle_database_domain_name'),
        sys_password              => hiera('oracle_database_sys_password'),
        system_password           => hiera('oracle_database_system_password'),
        character_set             => "AL32UTF8",
        nationalcharacter_set     => "UTF8",
        sample_schema             => 'FALSE',
        memory_percentage         => "40",
        memory_total              => "800",
        database_type             => "MULTIPURPOSE",
        em_configuration          => "NONE",
        storage_type              => "ASM",
        asm_snmp_password         => 'Welcome01',
        asm_diskgroup             => 'DATA',
        recovery_area_destination => 'DATA',
        require                   => Oradb::Opatch['19791420_db_patch_2'],
      }

## Oracle Database Client

    oradb::client{ '12.1.0.1_Linux-x86-64':
      version                   => '12.1.0.1',
      file                      => 'linuxamd64_12c_client.zip',
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/12.1/client',
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      download_dir              => '/install',
      bash_profile              => true,
      remote_file               => true,
      puppet_download_mnt_point => "puppet:///modules/oradb/",
      logoutput                 => true,
    }

or

    oradb::client{ '11.2.0.1_Linux-x86-64':
      version                   => '11.2.0.1',
      file                      => 'linux.x64_11gR2_client.zip',
      oracle_base               => '/oracle',
      oracle_home               => '/oracle/product/11.2/client',
      user                      => 'oracle',
      group                     => 'dba',
      group_install             => 'oinstall',
      download_dir              => '/install',
      bash_profile              => true,
      remote_file               => false,
      puppet_download_mnt_point => "/software",
      logoutput                 => true,
    }

## Enterprise Manager

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

    ora_init_param{'SPFILE/processes@soarepos':
      ensure => 'present',
      value  => '1000',
    }

    ora_init_param{'SPFILE/job_queue_processes@soarepos':
      ensure  => present,
      value   => '4',
    }

    db_control{'soarepos restart':
      ensure                  => 'running', #running|start|abort|stop
      instance_name           => hiera('oracle_database_name'),
      oracle_product_home_dir => hiera('oracle_home_dir'),
      os_user                 => hiera('oracle_os_user'),
      refreshonly             => true,
      subscribe               => [Ora_init_param['SPFILE/processes@soarepos'],
                                  Ora_init_param['SPFILE/job_queue_processes@soarepos'],],
    }

    ora_tablespace {'JMS_TS@soarepos':
      ensure                    => present,
      datafile                  => 'jms_ts.dbf',
      size                      => 100M,
      logging                   => yes,
      autoextend                => on,
      next                      => 100M,
      max_size                  => 1G,
      extent_management         => local,
      segment_space_management  => auto,
    }

    ora_role {'APPS@soarepos':
      ensure    => present,
    }

    ora_user{'JMS@soarepos':
      ensure                    => present,
      temporary_tablespace      => temp,
      default_tablespace        => 'JMS_TS',
      password                  => 'jms',
      require                   => [Ora_tablespace['JMS_TS@soarepos'],
                                    Ora_role['APPS@soarepos']],
      grants                    => ['SELECT ANY TABLE', 'CONNECT', 'CREATE TABLE', 'CREATE TRIGGER','APPS'],
      quotas                    => {
                                      "JMS_TS"  => 'unlimited'
                                    },
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

      oradb::goldengate{ 'ggate12.1.2':
        version                   => '12.1.2',
        file                      => '121200_fbo_ggs_Linux_x64_shiphome.zip',
        database_type             => 'Oracle',
        database_version          => 'ORA11g',
        database_home             => '/oracle/product/12.1/db',
        oracle_base               => '/oracle',
        goldengate_home           => "/oracle/product/12.1/ggate",
        manager_port              => 16000,
        user                      => 'ggate',
        group                     => 'dba',
        group_install             => 'oinstall',
        download_dir              => '/install',
        puppet_download_mnt_point => hiera('oracle_source'),
        require                   => User['ggate'],
      }

      file { "/oracle/product/11.2.1" :
        ensure        => directory,
        recurse       => false,
        replace       => false,
        mode          => '0775',
        owner         => 'ggate',
        group         => 'dba',
        require       => Oradb::Goldengate['ggate12.1.2'],
      }

      oradb::goldengate{ 'ggate11.2.1':
        version                   => '11.2.1',
        file                      => 'ogg112101_fbo_ggs_Linux_x64_ora11g_64bit.zip',
        tar_file                  => 'fbo_ggs_Linux_x64_ora11g_64bit.tar',
        goldengate_home           => "/oracle/product/11.2.1/ggate",
        user                      => 'ggate',
        group                     => 'dba',
        download_dir              => '/install',
        puppet_download_mnt_point => hiera('oracle_source'),
        require                   => File["/oracle/product/11.2.1"],
      }

      oradb::goldengate{ 'ggate11.2.1_java':
        version                   => '11.2.1',
        file                      => 'V38714-01.zip',
        tar_file                  => 'ggs_Adapters_Linux_x64.tar',
        goldengate_home           => "/oracle/product/11.2.1/ggate_java",
        user                      => 'ggate',
        group                     => 'dba',
        group_install             => 'oinstall',
        download_dir              => '/install',
        puppet_download_mnt_point => hiera('oracle_source'),
        require                   => File["/oracle/product/11.2.1"],
      }

## Oracle SOA Suite Repository Creation Utility (RCU)

product =
- soasuite
- webcenter
- all

RCU examples

soa suite repository

    oradb::rcu{'DEV_PS6':
      rcu_file       => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
      product        => 'soasuite',
      version        => '11.1.1.7',
      oracle_home    => '/oracle/product/11.2/db',
      user           => 'oracle',
      group          => 'dba',
      download_dir   => '/install',
      action         => 'create',
      db_server      => 'dbagent1.alfa.local:1521',
      db_service     => 'test.oracle.com',
      sys_password   => 'Welcome01',
      schema_prefix  => 'DEV',
      repos_password => 'Welcome02',
    }

webcenter repository with a fixed temp tablespace

    oradb::rcu{'DEV2_PS6':
      rcu_file          => 'ofm_rcu_linux_11.1.1.7.0_32_disk1_1of1.zip',
      product           => 'webcenter',
      version           => '11.1.1.7',
      oracle_home       => '/oracle/product/11.2/db',
      user              => 'oracle',
      group             => 'dba',
      download_dir      => '/install',
      action            => 'create',
      db_server         => 'dbagent1.alfa.local:1521',
      db_service        => 'test.oracle.com',
      sys_password      => 'Welcome01',
      schema_prefix     => 'DEV',
      temp_tablespace   => 'TEMP',
      repos_password    => 'Welcome02',
    }

delete a repository

    oradb::rcu{'Delete_DEV3_PS5':
      rcu_file          => 'ofm_rcu_linux_11.1.1.6.0_disk1_1of1.zip',
      product           => 'soasuite',
      version           => '11.1.1.6',
      oracle_home       => '/oracle/product/11.2/db',
      user              => 'oracle',
      group             => 'dba',
      download_dir      => '/install',
      action            => 'delete',
      db_server         => 'dbagent1.alfa.local:1521',
      db_service        => 'test.oracle.com',
      sys_password      => 'Welcome01',
      schema_prefix     => 'DEV3',
      repos_password    => 'Welcome02',
    }

OIM, OAM repository, OIM needs an Oracle Enterprise Edition database

    oradb::rcu{'DEV_1112':
      rcu_file                  => 'V37476-01.zip',
      product                   => 'oim',
      version                   => '11.1.2.1',
      oracle_home               => '/oracle/product/11.2/db',
      user                      => 'oracle',
      group                     => 'dba',
      download_dir              => '/data/install',
      action                    => 'create',
      db_server                 => 'oimdb.alfa.local:1521',
      db_service                => 'oim.oracle.com',
      sys_password              => hiera('database_test_sys_password'),
      schema_prefix             => 'DEV',
      repos_password            => hiera('database_test_rcu_dev_password'),
      puppet_download_mnt_point => $puppet_download_mnt_point,
      logoutput                 => true,
      require                   => Oradb::Dbactions['start oimDb'],
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
