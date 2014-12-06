#
#
#
define oradb::installem_agent(
  $version                     = '12.1.0.4',
  $install_type                = undef, #'agentPull'|'agentDeploy'
  $install_version             = '12.1.0.4.0',
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

  if (!( $version in ['12.1.0.4'])){
    fail('Unrecognized em agent version, use 12.1.0.4')
  }

  # check if the oracle software already exists
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

  if ( $continue ) {

    $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

    if $ora_inventory_dir == undef {
      $oraInventory = "${oracle_base_dir}/oraInventory"
    } else {
      $oraInventory = "${ora_inventory_dir}/oraInventory"
    }

    # setup oracle base with the right permissions
    oradb::utils::dbstructure{"oracle em agent structure ${version}":
      oracle_base_home_dir => $oracle_base_dir,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      os_group_install     => undef,
      os_group_oper        => undef,
      download_dir         => $download_dir,
      log_output           => $log_output,
      user_base_dir        => undef,
      create_user          => false,
    }

    # check oraInst
    oradb::utils::dborainst{"em agent orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group,
    }

    unless is_string($source) {fail('You must specify source') }
    unless is_string($agent_base_dir) {fail('You must specify agent_base_dir') }
    unless is_string($sysman_user) {fail('You must specify sysman_user') }
    unless is_string($sysman_password) {fail('You must specify sysman_password') }
    unless is_string($oracle_base_dir) {fail('You must specify oracle_base_dir') }
    unless is_string($agent_registration_password) {fail('You must specify agent_registration_password') }
    unless is_integer($em_upload_port) {fail('You must specify em_upload_port') }

    # chmod +x /tmp/AgentPull.sh
    if ( $install_type  == 'agentPull') {

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
        require   => Package['curl'],
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
      }

      $command = "${download_dir}/AgentPull.sh LOGIN_USER=${sysman_user} LOGIN_PASSWORD=${sysman_password} PLATFORM=\"${install_platform}\" AGENT_BASE_DIR=${agent_base_dir} AGENT_REGISTRATION_PASSWORD=${agent_registration_password} RSPFILE_LOC=${download_dir}/em_agent.properties"

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
                      Oradb::Utils::Dbstructure["oracle em agent structure ${version}"],
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

      exec { "extract ${download_dir}/${file1}":
        command   => "unzip -o ${source} -d ${download_dir}/em_agent_${version}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => [Oradb::Utils::Dbstructure["oracle em agent structure ${version}"],
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
        require   => [Exec["extract ${download_dir}/${file1}"],
                      Oradb::Utils::Dbstructure["oracle em agent structure ${version}"],
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