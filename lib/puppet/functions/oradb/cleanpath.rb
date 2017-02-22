require 'pathname'
# clean and return the path
Puppet::Functions.create_function(:'oradb::cleanpath') do

  # clean and return the path
  # @param path some directory
  # @return [String] Return the directory
  # @example clean directory
  #   oradb::cleanpath('/opt/oracle/db/11g/../') => '/opt/oracle/db'
  dispatch :cleanpath do
    param 'String', :path
    # return_type 'String'
  end

  def cleanpath(path)
    path2 = Pathname.new(path)
    path2.cleanpath.to_s
  end
end
