# frozen_string_literal: true

require 'spec_helper'

describe 'oradb::tnsnames', :type => :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) {'testDb_Create'}
      let(:facts) { os_facts }
      let(:params) do
        {
          'oracle_home' => '/oracle/product/11.2/db',
        }
      end

      it { is_expected.to compile }

    end
  end
end
