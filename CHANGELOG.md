# Version updates

## 2.0.6
- Seeded database template support
- oracle_hostname parameter for emagent
- puppet 4 fixes

## 2.0.5
- EM agent, Move sysman parameter validation to agentpull block
- Fix rcu status check, rollback from version 2.0.1
- ASM service fix for RHEL7

## 2.0.4
- dbtemplate_12.1.dbt database template should also work for 12.1.0.2
- db_structure fixes, correct permissions and chown order
- support for Enterprise Manager 12.1.0.5

## 2.0.3
- some more strict file permissions
- rcu allows now more complex passwords
- allow to change the service name instead of dbora
- installdb is_rack_one_install option for 12.1.0.2
- db_control type & dbcontrol manifest supports now also Grid
- security/permissions fixes with files which can contain passwords

## 2.0.2
- support the new opatchauto utility instead of opatch auto by use_opatchauto_utility => true
- support 12.1 CDB with custom database template
- changed the default oraInventory location when it is not defined

## 2.0.1
- bash_profile option for database clients
- rcu 11g fix
- 12.1.0.2 oracle client template
- db_listener type refreshonly fix

## 2.0.0
- All parameters of classes or defines are now in snake case and not in camel case

## 1.0.35
- Add support for Grid 12.1.0.2 (installasm)
- Fix unsetted vars in dbora template
- Added ability to put listener entries in tnsnames.ora

## 1.0.34
- autostart fix so it also works for Oracle Linux 5
- rcu prefix compare check fix ( Uppercase )
- RCU fixes for OIM or OAM 11.1.1.2.3
- installem em_upload_port parameter type fix

## 1.0.33
- Small Suse fix for the autostart service
- new installdb attribute cleanup_installfile
- option to provide the sys username for RCU

## 1.0.32
- be able to provide a listener name for starting the oracle listener ( manifest and custom type)

## 1.0.31
- installasm, stand alone parameter in combination with $grid_type == 'CRS_SWONLY' used as standalone or in RAC
- installasm, .profile fix for ORACLE_SID in case grid_type = HA_CONFIG -> +ASM or in grid_type = CRS_CONFIG -> +ASM1

## 1.0.30
- Removed Oracle Home under base check for ASM installations, in CRS_CONFIG or CRS_SWONLY this is not right

## 1.0.29
- Custom type for oracle db/asm/client/em directory structure instead of using dirtree and some oradb manifests

## 1.0.28
- fixed database install rsp 12.1.0.2
- db_listener custom puppet type/provider, listener.pp calls this type

## 1.0.27
- solaris fix for database.pp and opatch auto
- puppet_download_mnt_point parameter for database.pp which can be used for own db template

## 1.0.26
- Removed create_user functionality in installdb & client, Puppet should do it instead of oradb module
- Support for 12.1 pluggable database
- init_params of database.pp now also support a hash besides a comma separated string
- Refactored dbstructure so it works with multiple oracle homes
- Goldengate 12.1.2 now uses dbstructure

## 1.0.25
- added extra parameter validation to installdb, installasm and installem_agent
- opatch fix for opatch bundle zip files which has subfolders in the zip
- owner of the grid home or oracle home folder fix
- renamed clusterware parameter of the opatch type to opatch_auto
- storage_type parameter is now also used in the dbca command when using a database template
- Added ASM 11.2 Database template

## 1.0.24
- Enterprise Manager agent install with AgentPull & AgentDeploy
- Cleanup install zip files and extracted installation folder in installdb, installasm, installem and client

## 1.0.23
- Enterprise Manager 12.1.0.4 server installation support
- Support for Solaris 11.2
- autostart service for Solaris

## 1.0.22
- db_control puppet resource type, start or stop an instance or subscribe to changes like init_param
- Tnsnames change so it supports a TNS balanced configuration
- changed oraInst.loc permissions to 0755

## 1.0.21
- fix for windows/unix linefeed when oradb is used in combination with vagrant on a windows host
- opatch check bug when run it twice
- Add a tnsnames entry support

## 1.0.20
- Create a Database instance based on a template
- Be able to change the default listener port 1521 in net.pp & database.pp
- Opatch fix to apply same the patch twice on different oracle homes

## 1.0.19
- OPatch support for clusterware (GRID)
- Opatchupgrade now works for grid & database on the same node

## 1.0.18
- Puppet Lint fixes
- Rubocop fixes
- 12.1 Template fix for Oracle RAC

## 1.0.17
- Fix for puppet 3.7 and more strict parsing
- OPatch also checks for OPatch succeeded
- RAC installation parameters for database, installasm, installdb

## 1.0.16
- cleanup readme
- asm/grid for 12.1.0.1 & installasm fix for Oracle Restart fix, 11.2.0.1 rsp template fix

## 1.0.15
- RCU fix for multiple FMW Repositories, installasm fix with zip_extract = false

## 1.0.14
- Rename some internal manifest to avoid a conflict with orawls

## 1.0.13
- Oracle Database & Client 12.1.0.2 Support

## 1.0.11
- database client fix with remote file, set db_snmp_password on a database

## 1.0.10
- oraInst.loc bug fix, option to skip installdb bash profile

## 1.0.9
- 11.2 EE install options

## 1.0.8
- RCU & Opatch fixes in combination with ruby 1.9.3

## 1.0.7
- Added unit tests and OPatch upgrade support without OCM registration

## 1.0.6
- Grid install and ASM support

## 1.0.5
- refactored installdb and support for oinstall groups

## 1.0.4
- db_rcu native type used in rcu.pp

## 1.0.2
- db_opatch native type used in opatch.pp

## 1.0.1
- autostart multiple databases, small fixes

## 1.0.0
- oracle module add##on for user,role and tablespace creation

## 0.9.9
- em_configuration parameter for Database creation

## 0.9.7
- Oracle database 11.2.0.1, 12.1.0.1 client support, refactored installdb,net,goldengate
