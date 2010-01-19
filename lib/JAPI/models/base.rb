class JAPI::Model::Base < ActiveResource::Base
  
  cattr_accessor :client
  
  def initialize( attributes = {} )
    @attributes = HashWithIndifferentAccess.new(attributes)
    objectify_attributes!
  end
  
  protected
  
  def objectify_attributes!
    attributes.each do |key, value|
      key_klass = key.to_s.classify.constantize rescue nil
      next if key_klass.nil?
      case ( value ) when Array
        value.collect!{ |attrs| key_klass.new( attrs ) }
      when Hash
        key_klass.new( value )
      end
    end
  end
  
  def client
    self.class.client
  end
  
  def update
    result = client.api_call( self.class.element_update_path, Hash.from_xml( encode ) )
    errors.add( result[:data], result[:message] ) if result[:error]
    attributes.delete( :reorder ) unless result[:error]
    result[:error]
  end
  
  def create
    result = client.api_call( self.class.element_create_path, Hash.from_xml( encode ) )
    errors.add( result[:data], result[:message] ) if result[:error]
    attributes[:id] = result[:data] unless result[:error]
    result[:error]
  end
  
  class << self
    
    def exists?(id, options = {})
      result = client( element_show_path, ( options[:params] || {} ).merge( :id => id ) )
      !result[:error]
    end
    
    def delete( id, options = {} )
      client.api_call( element_delete_path, options[:params] || {} )
      result[:error]
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
    
    protected
    
    def find_single( id, options={} )
      result = client( element_show_path, options[:params].merge( :id => id ) )
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
      result[:error] ? [] : ::PaginatedCollection.new( result )
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