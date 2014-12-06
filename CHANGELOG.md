# Version updates

## 1.0.24
- Enterprise Manager agent install with AgentPull & AgentDeploy

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
- RCU fix for multiple FMW Repositories, installasm fix with zipExtract = false

## 1.0.14
- Rename some internal manifest to avoid a conflict with orawls

## 1.0.13
- Oracle Database & Client 12.1.0.2 Support

## 1.0.11
- database client fix with remote file, set DBSNMPPASSWORD on a database

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
- emConfiguration parameter for Database creation

## 0.9.7
- Oracle database 11.2.0.1, 12.1.0.1 client support, refactored installdb,net,goldengate
