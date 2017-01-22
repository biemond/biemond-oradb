# == define: oradb::utils::dborainst
#
#  creates oraInst.loc for oracle products
#
#
##
define oradb::utils::dborainst
(
  String $ora_inventory_dir = undef,
  String $os_group          = lookup('oradb::group'),
){
  $ora_inst_path = lookup('oradb::orainst_dir')
  if ( $facts['kernel'] == 'SunOS'){
    if !defined(File[$ora_inst_path]) {
      file { $ora_inst_path:
        ensure => directory,
        before => File["${ora_inst_path}/oraInst.loc"],
        mode   => '0755',
      }
    }
  }

  if !defined(File["${ora_inst_path}/oraInst.loc"]) {
    file { "${ora_inst_path}/oraInst.loc":
      ensure  => present,
      content => epp('oradb/oraInst.loc.epp',{ 'ora_inventory_dir' => $ora_inventory_dir,
                                               'os_group'          => $os_group}),
      mode    => '0755',
    }
  }
}
