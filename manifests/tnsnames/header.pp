class oradb::tnsnames::header()
{
  concat::fragment { 'header':
    target  => 'tnsnames.ora',
    content => '# This file is managed by Puppet.  Do not Edit!',
    order   => '00',
  }
}
