class JAPI::PaginatedCollection < Array
  
  attr_reader :pagination
  attr_reader :error
  attr_reader :data
  attr_reader :message
  
  def initialize( options = {} )
    @pagination = options[:pagination]
    @error      = options[:error]
    @data       = options[:data] if error
    @message    = options[:message]
    error ? super( [] ) : super( Array( options[:data] ) )
  end
  
end