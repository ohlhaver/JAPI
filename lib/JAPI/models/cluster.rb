class JAPI::Cluster < JAPI::Model::Base
  
  # Use find( :one, :params => { :cluster_id => 1 } )
  # Use find( :all, :params => { :cluster_ids => [1,2,3] } )
  
  def video_count
    attributes[:video_count] || 0
  end
  
  def blog_count
    attributes[:blog_count] || 0
  end
  
  def opinion_count
    attributes[:opinion_count] || 0
  end
  
  def filter_count
    video_count + blog_count + opinion_count
  end
  
  class << self
    
    def collection_path
      "search/stories/clusters"
    end
    
    def element_path
      "search/stories/clusters"
    end
    
  end
  
end