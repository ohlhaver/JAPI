class JAPI::NavigationLink
  
  cattr_accessor :prefix_options
  cattr_accessor :translation_prefix 
  
  self.prefix_options ||= { 
    :cluster_group => { :controller => :sections, :action => :show },
    :new_cluster_group => { :controller => :sections, :action => :new },
    :topic => { :controller => :topics, :action => :show },
    :new_topic => { :controller => :topics, :action => :new },
    :my_topics => { :controller => :topics, :action => :index },
    :top_authors => { :controller => :authors, :action => :top },
    :my_authors => { :controller => :authors, :action => :my },
  }
  
  self.translation_prefix = "navigation.main"
  
  attr_accessor :params
  attr_accessor :id
  attr_accessor :name
  attr_accessor :type
  attr_accessor :remote
  attr_accessor :translate
  attr_accessor :base # attribute to assign some base object
  
  def initialize( options = {} )
    options ||= {}
    options.reverse_merge!( :translate => true, :remote => false, :params => {} )
    @id = options[:id]
    @type = options[:type].to_sym
    @remote = options[:remote]
    @translate = options[:translate]
    @name = options[:name].to_s
    @name = I18n.t( "#{translation_prefix}.#{@name.gsub(' ', '_').underscore}" ) if @translate
    @params = options[:params]
  end
  
  def tap( &block )
    block.call( self )
    self
  end
  
  def to_url_hash( options = {} )
    url_hash = ( self.class.prefix_options[ self.type ] || {} ).reverse_merge( :id => self.id )
    url_hash.reverse_merge!( options.reverse_merge!( params ) )
    return url_hash
  end
  
end