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
          connect_service_name: 'service_name',
          server: { 'myserver' => { 'host' => '127.0.0.1', 'port' => '1521', 'protocol' => 'TCP' } },
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
          is_expected.to contain_concat__fragment('tnsnames').with(
            target: '/oracle/product/11.2/db/network/admin/tnsnames.ora',
          )
        end
      end

      context 'with entry_type => listener' do
        let(:params) do
          {
            connect_service_name: 'service_name',
            server: { 'myserver' => { 'host' => '127.0.0.1', 'port' => '1521', 'protocol' => 'TCP' } },
          }
        end

        it do
          is_expected.to contain_concat__fragment('tnsnames')
        end
      end
    end
  end
end
