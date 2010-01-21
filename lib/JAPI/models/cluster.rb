class JAPI::Cluster < JAPI::Model::Base
  
  # Use find( :one, :params => { :cluster_id => 1 } )
  # Use find( :all, :params => { :cluster_ids => [1,2,3] } )
  
  class << self
    
    def collection_path
      "search/stories/clusters"
    end
    
    def element_path
      "search/stories/clusters"
    end
    
  end
  
end