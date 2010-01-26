class JAPI::ClusterGroup < JAPI::Model::Base
  
  # Use find( :one, :params => { :cluster_group_id => 1 } )
  # Use find( :all, :params => { :cluster_group_ids => [1,2,3] } )
  
  def name
    attributes[:name].to_s.underscore.gsub(' ', '_')
  end
  
  class << self
    
    def collection_path
      "search/stories/cluster_groups"
    end
    
    def element_path
      "search/stories/cluster_groups"
    end
    
  end
  
end