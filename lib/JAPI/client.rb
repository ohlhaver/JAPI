class JAPI::Client
  
  attr_accessor :base_url
  attr_accessor :access_key
  attr_accessor :path_proxy
  
  def initialize( options = {} )
    @base_url   = options[:base_url]
    @access_key = options[:access_key]
    @path_proxy = Hash.new{ |h,k| h[k] = [] }
  end
  
  def api_call( path, params = {}, &block )
    params ||= {}
    url = URI.parse( api_request_url( path ) )
    request = Net::HTTP::Post.new( url.path )
    request.set_form_data( params )
    response = Net::HTTP.new( url.host, url.port ).start{ |http| http.request( request ) }
    result = ( Hash.from_xml( response.body ) rescue {} ).try( :[], 'response' )
    result ||= { :data => 'invalid api call', :error => 'true' }
    result.symbolize_keys!
    objectify_result_data!( result )
    if !result[ :error ] && block
      block.call( result[:data][:results], result[:data][:pagination] )
    end
    result
  end
  
  protected
  
  def api_request_url( path )
    "#{base_url}/api/#{access_key}/#{path}"
  end
  
  private
  
  def objectify_result_data!( result )
    return if result[:error] || !result[:data].is_a?( Hash )
    result[:data].each do |k, v|
      klass = k.classify.constantize rescue nil
      next unless klass
      if v.is_a?( Array )
        v.collect!{ |vv| klass.new( vv ) }
      else
        result[:data][k] = klass.new( v )
      end
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