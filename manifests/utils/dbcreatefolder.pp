# == define: oradb::utils::dbcreatefolder
#
define oradb::utils::dbcreatefolder(
  $prefix           = undef,
) {

  # remove prefix
  $dir_resource = regsubst($title, "(${prefix})(.*)$", '\2')
  # notice("folder = ${dir_resource}")
  if !defined(File[$dir_resource]) {
    file { $dir_resource:
      ensure  => directory,
    }
  }
}