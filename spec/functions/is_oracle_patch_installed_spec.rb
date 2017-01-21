require 'spec_helper'
require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

describe 'is_oracle_patch_installed', :type => :puppet_function do
  context 'when opatch_patches fact available' do
    let(:facts) do
      {
        :opatch_patches => {
          '/u01/app/oracle/product/12.1.0/dbhome_1' => [
            {
              'patch_id' => '21485069',
              'patch_desc' => ''
            },
            {
              'patch_id' => '21948354',
              'patch_desc' => 'Database Patch Set Update : 12.1.0.2.160119 (21948354)'
            }
          ]
        }
      }
    end
    context 'when patch is installed in oracle_home' do
      it { is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1', '21948354').and_return(true) }
    end
    context 'when oracle_home is not in opatch_patches fact' do
      it { is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/no_such_home', '21948354').and_return(false) }
    end
    context 'when patch is not installed in oracle_home' do
      it { is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1', '666666').and_return(false) }
    end
  end
  context 'when no opatch_patches fact' do
    it { is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1', '21948354').and_return(false) }
  end

  context 'with invalid parameters' do
    describe 'with wrong number of parameters' do
      it do
        is_expected.to run.with_params
          .and_raise_error(Puppet::ParseError, /is_oracle_patch_installed\(\): Wrong number of arguments/)
      end
      it do
        is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1')
          .and_raise_error(Puppet::ParseError, /is_oracle_patch_installed\(\): Wrong number of arguments/)
      end
    end

    describe 'with invalid oracle_home' do
      it do
        is_expected.to run.with_params('not_an_absolute_path', '666666')
          .and_raise_error(Puppet::ParseError, /oracle_home must be absolute path/)
      end
    end

    describe 'with invalid patch_id' do
      it do
        is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1', 6666)
          .and_raise_error(Puppet::ParseError, /^patch_id must be a string$/)
      end
      it do
        is_expected.to run.with_params('/u01/app/oracle/product/12.1.0/dbhome_1', 'invalid_string')
          .and_raise_error(Puppet::ParseError, /^patch_id must be a string of digits$/)
      end
    end
  end
end