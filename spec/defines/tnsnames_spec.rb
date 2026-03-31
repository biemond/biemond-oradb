# frozen_string_literal: true

require 'spec_helper'

describe 'oradb::tnsnames', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) { 'tnsnames' }
      let(:node) { 'test.example.com' }
      let(:facts) { os_facts }

      let(:params) do
        {
          oracle_home: '/oracle/product/11.2/db',
          connect_service_name: 'my_service_name',
          server: { 'myserver' => { 'host' => 'my_host', 'port' => '1521', 'protocol' => 'TCP' } },
          connect_timeout: 5,
          transport_connect_timeout: 5,
          retry_count: 3,
        }
      end

      context 'with basic parameters' do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_concat('/oracle/product/11.2/db/network/admin/tnsnames.ora').with(
            ensure:         'present',
            owner:          'oracle',
            group:          'dba',
            mode:           '0774',
            ensure_newline: true,
          )
        end

        it do
          is_expected.to contain_concat__fragment('tnsnames')
            .with_target('/oracle/product/11.2/db/network/admin/tnsnames.ora')
            .with_content(%r{^tnsnames =})
            .with_content(%r{^\s+\(DESCRIPTION =})
            .with_content(%r{^\s+\(CONNECT_TIMEOUT = 5})
            .with_content(%r{^\s+\(TRANSPORT_CONNECT_TIMEOUT = 5})
            .with_content(%r{^\s+\(RETRY_COUNT = 3})
            .with_content(%r{^\s+\(ADDRESS = \(PROTOCOL = TCP\)\(HOST = my_host\)\(PORT = 1521\)\)})
            .with_content(%r{^\s+\(SERVER = DEDICATED\)})
            .with_content(%r{^\s+\(SERVICE_NAME = my_service_name\)})
        end
      end

      context 'with entry_type => listener' do
        let(:params) do
          {
            connect_service_name: 'my_service_name',
            server: { 'myserver' => { 'host' => 'my_host', 'port' => '1521', 'protocol' => 'TCP' } },
          }
        end

        it do
          is_expected.to contain_concat__fragment('tnsnames')
        end
      end
    end
  end
end
