class JAPI::Client
  
  attr_accessor :base_url
  attr_accessor :access_key
  attr_accessor :path_proxy
  attr_accessor :timeout
  
  def initialize( options = {} )
    @base_url   = options[:base_url]
    @access_key = options[:access_key]
    @timeout = ( options[:timeout] || 10 ).to_i
    @path_proxy = Hash.new{ |h,k| h[k] = [] }
  end
  
  def api_call( path, params = {}, &block )
    params ||= {}
    response = api_response( path, params )
    result = ( Hash.from_xml( response ) rescue nil ).try( :[], 'response' )
    result ||= Hash.from_xml( incorrect_format_api_call_response( path ) )[ 'response' ]
    result.symbolize_keys!
    objectify_result_data!( result )
    if !result[ :error ] && block
      block.call( result[:data], result[:pagination] )
    end
    result
  end
  
  def api_response( path, params )
    url = URI.parse( api_request_url( path ) )
    request = Net::HTTP::Post.new( url.path )
    # Multiple Params Fix
    params.each{ |k,v| next unless v.is_a?(Array); params[k] = v.join(',') }
    request.set_form_data( params )
    Timeout::timeout( self.timeout ) {
      response = Net::HTTP.new( url.host, url.port ).start{ |http| http.request( request ) } rescue nil
      return response.try( :body ) || invalid_api_call_response( path )
    }
    return timeout_api_call_response( path )
  end
  
  def api_request_url( path )
    "#{base_url}/api/#{access_key}/#{path}"
  end
  
  protected
  
  def incorrect_format_api_call_response( path )
    { :error => true, :message => 'api.format.invalid', :data => path }.to_xml( :root => 'response' )
  end
  
  def invalid_api_call_response( path )
    { :error => true, :message => 'api.action.invalid', :data => path }.to_xml( :root => 'response' )
  end
  
  def timeout_api_call_response( path )
    { :error => true, :message => "api.request.timeout.#{timeout}.seconds", :data => path }.to_xml( :root => 'response')
  end
  
  private
  
  def objectify_result_data!( result )
    return if result[:error] || !result[:data].is_a?( Hash )
    result[:data].each do |k, v|
      object = JAPI::Model::Base.new_factory( k, v )
      next unless object
      result[:data][k] = object
    end
    result[:data].symbolize_keys!
    key = result[:data].keys.select{ |x| x != :pagination }.first
    result[:pagination] = result[:data][:pagination]
    result[:data] = result[:data].delete( key )
  end
  
  def method_missing( method_name, *args, &block )
    if args.empty? && block.nil?
      path_proxy[ Thread.current.object_id ].push( method_name.to_s )
      self
    elsif args.first.is_a?( Hash ) || !block.nil?
      path = path_proxy.delete( Thread.current.object_id )
      path.push( method_name.to_s )
      api_call( path.join('/') , args.first || {}, &block )
    else
      super
    end
  end
  
end