class Topic < JAPI::Model::Base
  
  class << self
    
    def collection_path
      "search/stories/topics"
    end
    
    def element_path
      "search/stories/topics"
    end
    
  end
  
end