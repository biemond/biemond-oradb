require 'spec_helper'

describe 'oradb::database_pluggable', type: :define do
  describe 'wrong database version' do
    let(:params) do
      {
        ensure: 'present',
        oracle_home_dir: '/oracle/product/11.2/db',
        version: '11.2',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_name: 'pdb1',
        pdb_datafile_destination: '/aa/aaa',
        pdb_admin_username: 'pdb_adm',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a match for Enum})
    end
  end

  describe 'unknown action' do
    let(:params) do
      {
        ensure: 'xxx',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_name: 'pdb1',
        pdb_datafile_destination: '/aa/aaa',
        pdb_admin_username: 'pdb_adm',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a match for Enum})
    end
  end

  describe 'create pdb 1' do
    let(:params) do
      {
        ensure: 'present',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_name: 'pdb1',
        pdb_admin_username: 'pdb_adm',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a String value, got Undef})
    end
  end

  describe 'create pdb 2' do
    let(:params) do
      {
        ensure: 'present',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_name: 'pdb1',
        pdb_datafile_destination: '/aa/aaa',
        pdb_admin_username: 'pdb_adm',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a String value, got Undef})
    end
  end

  describe 'create pdb 3' do
    let(:params) do
      {
        ensure: 'present',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_datafile_destination: '/aa/aaa',
        pdb_admin_username: 'pdb_adm',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a String value, got Undef})
    end
  end

  describe 'create pdb 4' do
    let(:params) do
      {
        ensure: 'present',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        pdb_name: 'pdb1',
        pdb_datafile_destination: '/aa/aaa',
        pdb_admin_username: 'pdb_adm',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a String value, got Undef})
    end
  end

  describe 'drop pdb' do
    let(:params) do
      {
        ensure: 'absent',
        oracle_home_dir: '/oracle/product/12.1/db',
        version: '12.1',
        user: 'oracle',
        group: 'dba',
        source_db: 'orcl',
        pdb_name: 'pdb1',
        pdb_admin_password: 'Welcome01',
      }
    end
    let(:title) { 'pdb1' }
    let(:facts) do
      { operatingsystem: 'CentOS',
        kernel: 'Linux',
        osfamily: 'RedHat', }
    end

    it do
      expect do
        is_expected.to contain_exec('dbca pdb execute pdb1')
      end.to raise_error(Puppet::Error, %r{expects a String value, got Undef})
    end
  end
end
