class JAPI::Model::Base < ActiveResource::Base
  
  cattr_accessor :client
  
  def initialize( attributes = {} )
    @prefix_options = {}
    load( attributes )
  end
  
  def destroy
    self.class.delete( to_param )
  end
  
  def save
    new_record? ? create : update
  end
  
  def to_hash
    hash = Hash.new
    attributes.each{ |k,v|
      hash[ k.to_sym ] = v.is_a?( JAPI::Model::Base ) ? v.to_hash : ( v.is_a?(Array) && v.inject(true){|s,x| s && x.is_a?( JAPI::Model::Base )} ? 
        v.collect{ |x| x.to_hash } : v )
    }
    return hash
  end
  
  protected
  
  def load( attributes )
    @attributes = HashWithIndifferentAccess.new( attributes )
    objectify_attributes!
  end
  
  def objectify_attributes!
    attributes.each do |key, value|
      object_value = self.class.new_factory( key, value )
      next unless object_value
      attributes[ key ] = object_value
    end
  end
  
  def client
    self.class.client
  end
  
  def update
    prefix_options.symbolize_keys!
    result = client.api_call( self.class.element_update_path, { self.class.element_name.to_sym => self.to_hash, :id => self.to_param }.reverse_merge( prefix_options ) )
    errors.add_to_base( result[:data] ) if result[:error]
    !result[:error]
  end
  
  def create
    prefix_options.symbolize_keys!
    result = client.api_call( self.class.element_create_path, { self.class.element_name.to_sym => self.to_hash }.reverse_merge( prefix_options ) )
    errors.add( result[:data], result[:message] ) if result[:error]
    attributes[:id] = result[:data] unless result[:error]
    !result[:error]
  end
  
  class << self
    
    def exists?(id, options = {})
      options[:params] ||= {}
      options[:params].symbolize_keys!
      options[:params].merge!( :id => id )
      result = self.client.api_call( element_path, options[:params] )
      !result[:error]
    end
    
    def delete( id, options = {} )
      options[:params] ||= {}
      options[:params].symbolize_keys!
      options[:params].merge!( :id => id )
      result = self.client.api_call( element_delete_path, options[:params] )
      !result[:error]
    end
    
    def collection_path
      "list/#{collection_name}"
    end
    
    def element_path
      "read/#{collection_name}"
    end
    
    def element_create_path
      "create/#{collection_name}"
    end
    
    def element_update_path
      "update/#{collection_name}"
    end
    
    def element_delete_path
      "delete/#{collection_name}"
    end
    
    def element_name
      self.name.gsub('JAPI::', '').underscore
    end
    
    def new_factory( key, value = {} )
      klass_name = key.to_s.classify
      return nil unless JAPI.constants.include?( klass_name ) && ( value.is_a?( Hash ) || ( value.is_a?( Array ) && value.inject( true ){ |s,x| x.is_a?( Hash ) } ) )
      klass = JAPI.const_get( klass_name )
      case ( value ) when Array :
        value.collect{ |attrs| klass.new( attrs ) }
      else
        klass.new( value )
      end
    end
    
    protected
    
    def find_single( id, options={} )
      options[:params] ||= {}
      options[:params].symbolize_keys!
      options[:params].merge!( :id => id )
      result = client.api_call( element_path, options[:params] )
      result[:error] ? nil : result[:data]
    end
    
    def find_every(options)
      result = case from = options[:from]
      when Symbol :
        client.api_call( "#{collection_path}/#{from}", options[:params] || {} )
      when String :
        client.api_call( from, options[:params] || {} )
      else
        client.api_call( collection_path, options[:params] )
      end
      result[:error] ? [] : JAPI::PaginatedCollection.new( result )
    end
    
    # Find a single resource from a one-off URL
    def find_one(options)
      result = case from = options[:from]
      when Symbol :
        client.api_call( "#{collection_path}/#{from}", options[:params] || {} )
      when String :
        client.api_call( from, options[:params] || {} )
      end
      result[:error] ? nil : Array( result[:data] ).first
    end
    
    def collection_name
      @collection_name ||= element_name.pluralize
    end
    
  end
  
end