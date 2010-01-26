$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'
gem 'activesupport', :version => '>=2.3.4'
gem 'activeresource', :version => '>=2.3.4'
require 'ostruct'
require 'net/http'
require 'activesupport'
require 'activeresource'

module JAPI
  VERSION = '1.2.0'
  module Model
  end
end

require 'JAPI/client'
require 'JAPI/models/base'
require 'JAPI/models/paginated_collection'
Dir[ File.dirname(__FILE__) + '/JAPI/models/*.rb' ].each do |model|
  require model
end

def JAPI.rails_init( env, root, log_level, file )
  options = YAML.load( IO.read( root + file ) )
  JAPI.send( :remove_const, :Config ) rescue
  JAPI.const_set( :Config, { :client => options['client'][ env ].symbolize_keys, :connect => options['connect'][env].symbolize_keys } )
  JAPI::Model::Base.client = JAPI::Client.new( JAPI::Config[:client] )
  if JAPI::Config[:connect]
    JAPI::Config[:connect][:account_server] = URI.parse( JAPI::Config[:connect][:account_server] )
    gem 'rubycas-client', :version => '2.1.0'
    require 'casclient'
    require 'casclient/frameworks/rails/filter'
    cas_logger = JAPI::Config[:connect][:log_file] ? Logger.new( root + JAPI::Config[:connect][:log_file] ) : nil
    cas_logger.try( :level=, log_level )
    CASClient::Frameworks::Rails::Filter.configure(
      :cas_base_url => JAPI::Config[:connect][:login_server],
      :username_session_key => :cas_user,
      :extra_attributes_session_key => :cas_user_attrs,
      :logger => cas_logger,
      :authenticate_on_every_request => false
    )
    require 'JAPI/connect'
  end
end