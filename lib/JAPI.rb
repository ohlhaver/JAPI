$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'
gem 'activesupport', :version => '>=2.3.4'
gem 'activeresource', :version => '>=2.3.4'
require 'net/http'
require 'activesupport'
require 'activeresource'
module JAPI
  VERSION = '1.0.0'
  module Model
  end
end
require 'JAPI/client'
require 'JAPI/models/base'
require 'JAPI/models/paginated_collection'
Dir[ File.dirname(__FILE__) + '/JAPI/models/*.rb' ].each do |model|
  require model
end