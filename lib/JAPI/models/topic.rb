class JAPI::Topic < JAPI::Model::Base
  
  # Use find( :one, :params => { :topic_id => 1 } )
  # Use find( :all, :params => { :topic_ids => [1,2,3] } )
  
  class << self
    
    def collection_path
      "search/stories/topics"
    end
    
    def element_path
      "search/stories/topics"
    end
    
  end
  
end