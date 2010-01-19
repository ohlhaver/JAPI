class Cluster < JAPI::Model::Base
  
  class << self
    
    def collection_path
      "search/stories/clusters"
    end
    
    def element_path
      "search/stories/clusters"
    end
    
  end
  
end