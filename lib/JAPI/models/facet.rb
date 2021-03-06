class JAPI::FacetCollection < Array
  
  def initialize( *args )
    super
  end
  
  def count
    select{ |facet| facet.value == :all && facet.filter == :count }.first.try( :count ) || 0
  end
  
  def filter_count
    video_count + blog_count + opinion_count
  end
  
  def category_count( category_id )
    select{ |facet| facet.value == category_id.to_i && facet.filter == :category_id }.first.try( :count ) || 0
  end
  
  def blog_count
    select{ |facet| facet.value == true && facet.filter == :is_blog }.first.try( :count ) || 0
  end
  
  def video_count
    select{ |facet| facet.value == true && facet.filter == :is_video }.first.try( :count ) || 0
  end
  
  def opinion_count
    select{ |facet| facet.value == true && facet.filter == :is_opinion }.first.try( :count ) || 0
  end
  
  def language_count( language_id )
    select{ |facet| facet.value.to_i == language_id.to_i && facet.filter == :language_id }.first.try( :count ) || 0
  end
  
end

class JAPI::Facet < JAPI::Model::Base
  
end