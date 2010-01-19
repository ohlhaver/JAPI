class PaginatedCollection < Array
  
  attr_reader :pagination
  
  def initialize( options = {} )
    @pagination = options[:pagination]
    super( options[:data] )
  end
  
end