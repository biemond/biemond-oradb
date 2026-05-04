require 'spec_helper'

describe 'oradb::database', type: :define do
  describe 'wrong database version' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.1',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        db_domain: 'xxxxx',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{expects a match for Enum})
    end
  end

  describe 'wrong action' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'xxxxx',
        db_domain: 'xxxxx',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{expects a match for Enum})
    end
  end

  describe 'wrong database_type' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        database_type: 'XXXX',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{for Enum})
    end
  end

  describe 'wrong em_configuration' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        em_configuration: 'XXXX',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{match for Enum})
    end
  end

  describe 'wrong storage_type' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        storage_type: 'XXXX',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{match for Enum})
    end
  end

  describe 'container database on 11.2' do
    let(:params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        container_database: true,
        db_domain: 'a',
      }
    end
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_file('/install/database_testDb_Create.rsp')
      end.to raise_error(Puppet::Error, %r{container or pluggable database is not supported on version 11.2})
    end
  end

  describe 'init params' do
    let(:title) { 'testDb_Create' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end
    let(:base_params) do
      {
        oracle_base: '/oracle',
        oracle_home: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        download_dir: '/install',
        action: 'create',
        db_domain: 'a',
      }
    end

    describe 'specified as a String' do
      let(:params) { base_params.merge(init_params: 'a=1,b=2') }

      it 'passes' do
        expect do
          is_expected.to contain_file('/install/database_testDb_Create.rsp')
        end.to raise_error(Puppet::Error, %r{Hash})
      end
    end

    describe 'specified as a Hash' do
      let(:params) { base_params.merge!(init_params: { 'a' => 'a', 'b' => 'b' }) }

      it 'fails' do
        expect do
          is_expected.to contain_file('/install/database_testDb_Create.rsp')
        end.not_to raise_error
      end
    end

    describe 'specified as an Array' do
      let(:params) { base_params.merge(init_params: [1, 2, 3, 4, 5]) }

      it 'fails' do
        expect do
          is_expected.to contain_file('/install/database_testDb_Create.rsp')
        end.to raise_error(Puppet::Error, %r{Hash})
      end
    end
  end
end
