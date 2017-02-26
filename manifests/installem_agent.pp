#
# installem_agent
#
# install the enterprise manager agent
#
# @example em agent install
#
#  oradb::installem_agent{ 'em12104_agent':
#      version                     => '12.1.0.4',
#      source                      => 'https://10.10.10.25:7802/em/install/getAgentImage',
#      install_type                => 'agentPull',
#      install_platform            => 'Linux x86-64',
#      oracle_base_dir             => '/oracle',
#      agent_base_dir              => '/oracle/product/12.1/agent',
#      agent_instance_home_dir     => '/oracle/product/12.1/agent/agent_inst',
#      sysman_user                 => 'sysman',
#      sysman_password             => 'Welcome01',
#      agent_registration_password => 'Welcome01',
#      agent_port                  => 1830,
#      oms_host                    => '10.10.10.25',
#      oms_port                    => 7802,
#      em_upload_port              => 4903,
#      user                        => 'oracle',
#      group                       => 'dba',
#      download_dir                => '/var/tmp/install',
#      log_output                  => true,
#      oracle_hostname             => 'emdb.example.com',
#  }
#
#  oradb::installem_agent{ 'em12104_agent2':
#      version                     => '12.1.0.4',
#      source                      => '/var/tmp/install/agent.zip',
#      install_type                => 'agentDeploy',
#      oracle_base_dir             => '/oracle',
#      agent_base_dir              => '/oracle/product/12.1/agent2',
#      agent_instance_home_dir     => '/oracle/product/12.1/agent2/agent_inst',
#      agent_registration_password => 'Welcome01',
#      agent_port                  => 1832,
#      oms_host                    => '10.10.10.25',
#      em_upload_port              => 4903,
#      user                        => 'oracle',
#      group                       => 'dba',
#      download_dir                => '/var/tmp/install',
#      log_output                  => true,
#  }
#
# @param version Oracle installation EM version
# @param install_type
# @param oracle_base_dir full path to the Oracle Base directory
# @param agent_base_dir full path to the Oracle Agent Home directory inside Oracle Base
# @param ora_inventory_dir full path to the Oracle Inventory location directory
# @param user operating system user
# @param group the operating group name for using the oracle software# @param group_install the operating group name for the installed software
# @param download_dir location for installation files used by this module
# @param log_output log all output
# @param install_version EM agent version
# @param install_platform EM agent OS install
# @param source url or local install file
# @param agent_instance_home_dir oracle em agent home
# @param agent_registration_password em registration password
# @param agent_port agent listen port
# @param sysman_user sysman username 
# @param sysman_password sysman user password
# @param oms_host oms host
# @param oms_port oms port number
# @param em_upload_port em upload port
# @param oracle_hostname the FQDN hostname to install the agent on
# @param manage_curl download curl package
#
define oradb::installem_agent(
  Enum['12.1.0.4','12.1.0.5'] $version           = '12.1.0.5',
  Enum['agentPull', 'agentDeploy'] $install_type = undef,
  String $install_version                        = '12.1.0.5.0',
  String $install_platform                       = 'Linux x86-64',
  String $source                                 = undef, # 'https://<OMS_HOST>:<OMS_PORT>/em/install/getAgentImage'|'/tmp/12.1.0.4.0_AgentCore_226_Linux_x64.zip'
  Optional[String] $ora_inventory_dir            = undef,
  String $oracle_base_dir                        = undef,
  String $agent_base_dir                         = undef,
  String $agent_instance_home_dir                = undef,
  String $agent_registration_password            = undef,
  Integer $agent_port                            = 1830,
  String $sysman_user                            = 'sysman',
  Optional[String] $sysman_password              = undef,
  String $oms_host                               = undef, # 'emapp.example.com'
  Integer $oms_port                              = undef, # 7802
  Integer $em_upload_port                        = undef, # 14511
  String $user                                   = lookup('oradb::user'),
  String $group                                  = lookup('oradb::group_install'),
  String $download_dir                           = lookup('oradb::download_dir'),
  Boolean $log_output                            = false,
  String $oracle_hostname                        = undef, # FQDN hostname where to install on
  Boolean $manage_curl                           = true,
)
{

  $supported_em_versions = join( lookup('oradb::enterprise_manager_agent_versions'), '|')
  if ( $version in $supported_em_versions == false ){
    fail("Unrecognized em version, use ${supported_em_versions}")
  }

  # check if the oracle software already exists
  validate_absolute_path( $agent_base_dir )
  $found = oradb::oracle_exists( $agent_base_dir )

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
    $ora_inventory = oradb::cleanpath("${oracle_base_dir}/../oraInventory")
  } else {
    validate_absolute_path($ora_inventory_dir)
    $ora_inventory = "${ora_inventory_dir}/oraInventory"
  }

  # setup oracle base with the right permissions
  db_directory_structure{"oracle em agent structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base_dir,
    ora_inventory_dir => $ora_inventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group,
  }

  if ( $continue ) {

    $exec_path = lookup('oradb::exec_path')

    # check oraInst
    oradb::utils::dborainst{"em agent orainst ${version}":
      ora_inventory_dir => $ora_inventory,
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

      if $manage_curl and !defined(Package['curl']) {
        package { 'curl':
          ensure  => present,
        }
      }

      exec { "agentPull ${title}":
        command   => "curl ${source} --insecure -o ${download_dir}/AgentPull.sh",
        timeout   => 0,
        logoutput => $log_output,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        require   => [Package['curl'],
                      Db_directory_structure["oracle em agent structure ${version}"],],
      }

      exec { "chmod ${title}":
        command   => "chmod +x ${download_dir}/AgentPull.sh",
        timeout   => 0,
        logoutput => $log_output,
        path      => $exec_path,
        user      => $user,
        group     => $group,
        require   => Exec["agentPull ${title}"],
      }

      file { "${download_dir}/em_agent.properties":
        ensure  => present,
        content => epp('oradb/em_agent_pull.properties.epp', {
                        'agent_instance_home_dir' => $agent_instance_home_dir,
                        'oms_host'                => $oms_host,
                        'oms_port'                => $oms_port,
                        'agent_port'              => $agent_port,
                        'em_upload_port'          => $em_upload_port } ),
        mode    => '0755',
        owner   => $user,
        group   => $group,
        require => Db_directory_structure["oracle em agent structure ${version}"],
      }

      $command = "${download_dir}/AgentPull.sh LOGIN_USER=${sysman_user} LOGIN_PASSWORD=${sysman_password} PLATFORM=\"${install_platform}\" VERSION=${install_version} AGENT_BASE_DIR=${agent_base_dir} AGENT_REGISTRATION_PASSWORD=${agent_registration_password} ORACLE_HOSTNAME=${oracle_hostname} RSPFILE_LOC=${download_dir}/em_agent.properties"

      exec { "agentPull execute ${title}":
        command   => $command,
        timeout   => 0,
        logoutput => $log_output,
        path      => $exec_path,
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
        path      => $exec_path,
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
        path      => $exec_path,
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
        path      => $exec_path,
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
        path      => $exec_path,
        cwd       => $agent_base_dir,
        logoutput => $log_output,
        require   => Exec["agentDeploy execute ${title}"],
      }

    } else {
      fail('Unrecognized install_type, use agentDeploy or agentPull' )
    }
  }
}
