class oradb::test(
  Enum["SE", "EE", "SEONE"] $database_type = lookup('oradb:installdb:database_type')
)
{}
