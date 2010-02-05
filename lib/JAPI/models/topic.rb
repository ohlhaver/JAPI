class JAPI::Topic < JAPI::Model::Base
  
  # Use find( :one, :params => { :topic_id => 1 } )
  # Use find( :all, :params => { :topic_ids => [1,2,3] } )
  
  # Last 24 hours
  def home_count( time_span )
    time_span = 24.hours.to_i if time_span.nil? || time_span.to_i > 24.hours.to_i
    result = self.class.find( :one, :params => self.prefix_options.merge( :topic_id => self.id, :time_span => time_span, :per_page => 0 ) )
    result.facets.count
  end
  
  class << self
    
    def collection_path
      "search/stories/topics"
    end
    
    def element_path
      "search/stories/topics"
    end
    
  end
  
end