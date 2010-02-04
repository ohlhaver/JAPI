class JAPI::TopicPreference < JAPI::Model::Base
  
  def self.map
    @@map ||= {
      :search_any => :q,
      :search_all => :qa,
      :search_exact_phrase => :qe,
      :search_except => :qn,
      :sort_criteria => :sc,
      :subscription_type => :st,
      :blog => :bp,
      :video => :vp,
      :opinion => :op,
      :author_id => :aid,
      :source_id => :sid,
      :category_id => :cid,
      :region_id => :rid
    }
  end
  
  # from topic -> advance_search
  def self.normalize!( params = {})
    map.each{ |k,v|
      value = params.delete( k )
      params[v] = value if value
    }
    params
  end
  
  # from advance_search -> topic
  def self.extract( params = {} )
    attributes = Hash.new
    map.each{ |k,v|
      attributes[k] = params[k] || params[v]
    }
    return attributes
  end
  
  fields :search_all, :search_any, :search_exact_phrase, :search_except, :sort_criteria, :time_span,
    :category_id, :region_id, :author_id, :source_id, :blog, :video, :opinion, :subscription_type, :name,
    :advanced
    
end