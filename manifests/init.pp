# == Class: oradb
#
class oradb ($shout = false) {

  if $::oradb::shout {
    notify {'oradb init.pp':}
  }

}
