#
#
#
define oradb::installem_agent(
  $version                     = '12.1.0.5',
  $install_type                = undef, #'agentPull'|'agentDeploy'
  $install_version             = '12.1.0.5.0',
  $install_platform            = 'Linux x86-64',
  $source                      = undef, # 'https://<OMS_HOST>:<OMS_PORT>/em/install/getAgentImage'|'/tmp/12.1.0.4.0_AgentCore_226_Linux_x64.zip'
  $ora_inventory_dir           = undef,
  $oracle_base_dir             = undef,
  $agent_base_dir              = undef,
  $agent_instance_home_dir     = undef,
  $agent_registration_password = undef,
  $agent_port                  = 1830,
  $sysman_user                 = 'sysman',
  $sysman_password             = undef,
  $oms_host                    = undef, # 'emapp.example.com'
  $oms_port                    = undef, # 7802
  $em_upload_port              = undef, # 14511
  $user                        = 'oracle',
  $group                       = 'oinstall',
  $download_dir                = '/install',
  $log_output                  = false,
)
{

  if (!( $version in ['12.1.0.4', '12.1.0.5'])){
    fail('Unrecognized em agent version, use 12.1.0.4 or 12.1.0.5')
  }

  # check if the oracle software already exists
  validate_absolute_path( $agent_base_dir )
  $found = oracle_exists( $agent_base_dir )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installem_agent ${agent_base_dir} does not exists":}
      $continue = true
    }
  }

  validate_absolute_path($oracle_base_dir)
  if $ora_inventory_dir == undef {
    $oraInventory = pick($::oradb_inst_loc_data,oradb_cleanpath("${oracle_base_dir}/../oraInventory"))
  } else {
    validate_absolute_path($ora_inventory_dir)
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  # setup oracle base with the right permissions
  db_directory_structure{"oracle em agent structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base_dir,
    ora_inventory_dir => $oraInventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group,
  }

  if ( $continue ) {

    $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

    # check oraInst
    oradb::utils::dborainst{"em agent orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group,
    }

    if ( $source == undef or is_string($source) == false) {fail('You must specify source') }
    if ( $agent_base_dir == undef or is_string($agent_base_dir) == false) {fail('You must specify agent_base_dir') }
    if ( $oracle_base_dir == undef or is_string($oracle_base_dir) == false) {fail('You must specify oracle_base_dir') }
    if ( $agent_registration_password == undef or is_string($agent_registration_password) == false) {fail('You must specify agent_registration_password') }
    if ( $em_upload_port == undef or is_numeric($em_upload_port) == false) {fail('You must specify em_upload_port') }

    # chmod +x /tmp/AgentPull.sh
    if ( $install_type  == 'agentPull') {

      if ( $sysman_user == undef or is_string($sysman_user) == false) {fail('You must specify sysman_user') }
      if ( $sysman_password == undef or is_string($sysman_password) == false) {fail('You must specify sysman_password') }

      if !defined(Package['curl']) {
        package { 'curl':
          ensure  => present,
        }
      }

      exec { "agentPull ${title}":
        command   => "curl ${source} --insecure -o ${download_dir}/AgentPull.sh",
        timeout   => 0,
        logoutput => $log_output,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => [Package['curl'],
                      Db_directory_structure["oracle em agent structure ${version}"],],
      }

      exec { "chmod ${title}":
        command   => "chmod +x ${download_dir}/AgentPull.sh",
        timeout   => 0,
        logoutput => $log_output,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["agentPull ${title}"],
      }

      file { "${download_dir}/em_agent.properties":
        ensure  => present,
        content => template('oradb/em_agent_pull.properties.erb'),
        mode    => '0755',
        owner   => $user,
        group   => $group,
        require => Db_directory_structure["oracle em agent structure ${version}"],
      }

      $command = "${download_dir}/AgentPull.sh LOGIN_USER=${sysman_user} LOGIN_PASSWORD=${sysman_password} PLATFORM=\"${install_platform}\" VERSION=${install_version} AGENT_BASE_DIR=${agent_base_dir} AGENT_REGISTRATION_PASSWORD=${agent_registration_password} RSPFILE_LOC=${download_dir}/em_agent.properties"

      exec { "agentPull execute ${title}":
        command   => $command,
        timeout   => 0,
        logoutput => $log_output,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => [Exec["agentPull ${title}"],
                      Exec["chmod ${title}"],
                      File["${download_dir}/em_agent.properties"],
                      Db_directory_structure["oracle em agent structure ${version}"],
                      Oradb::Utils::Dborainst["em agent orainst ${version}"],],
      }

      exec { "run em agent root.sh script ${title}":
        command   => "${agent_base_dir}/core/${install_version}/root.sh",
        user      => 'root',
        group     => 'root',
        path      => $execPath,
        cwd       => $agent_base_dir,
        logoutput => $log_output,
        require   => Exec["agentPull execute ${title}"],
      }

    } elsif ( $install_type  == 'agentDeploy') {

      if !defined(Package['unzip']) {
        package { 'unzip':
          ensure  => present,
        }
      }

      exec { "extract ${source} ${title}":
        command   => "unzip -o ${source} -d ${download_dir}/em_agent_${version}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => [Db_directory_structure["oracle em agent structure ${version}"],
                      Oradb::Utils::Dborainst["em agent orainst ${version}"],],
      }

      if ( $agent_instance_home_dir == undef ) {
        $command = "${download_dir}/em_agent_${version}/agentDeploy.sh AGENT_BASE_DIR=${agent_base_dir} AGENT_REGISTRATION_PASSWORD=${agent_registration_password} OMS_HOST=${oms_host} AGENT_PORT=${agent_port} EM_UPLOAD_PORT=${em_upload_port}"
      } else {
        $command = "${download_dir}/em_agent_${version}/agentDeploy.sh AGENT_BASE_DIR=${agent_base_dir} AGENT_INSTANCE_HOME=${agent_instance_home_dir} AGENT_REGISTRATION_PASSWORD=${agent_registration_password} OMS_HOST=${oms_host} AGENT_PORT=${agent_port} EM_UPLOAD_PORT=${em_upload_port}"
      }

      exec { "agentDeploy execute ${title}":
        command   => $command,
        timeout   => 0,
        logoutput => $log_output,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => [Exec["extract ${source} ${title}"],
                      Db_directory_structure["oracle em agent structure ${version}"],
                      Oradb::Utils::Dborainst["em agent orainst ${version}"],],
      }

      exec { "run em agent root.sh script ${title}":
        command   => "${agent_base_dir}/core/${install_version}/root.sh",
        user      => 'root',
        group     => 'root',
        path      => $execPath,
        cwd       => $agent_base_dir,
        logoutput => $log_output,
        require   => Exec["agentDeploy execute ${title}"],
      }

    } else {
      fail('Unrecognized install_type, use agentDeploy or agentPull' )
    }
  }
}
