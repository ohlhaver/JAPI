class JAPI::Pagination < JAPI::Model::Base
  
  def current_page
    attributes.try( :[], :current_page ) || 1
  end
  
  def total_pages
    attributes.try( :[], :total_pages ) || 1
  end
  
  def previous_page
    attributes.try( :[], :previous_page )
  end
  
  def next_page
    attributes.try( :[], :next_page )
  end
  
  def numbered_pages
    start_page = ( current_page > 5 && total_pages > 10 ) ? ( ( current_page + 5 < total_pages ) ? current_page - 5 + 1 : total_pages - 10 + 1 ) : 1
    end_page =  total_pages > 10 ? ( start_page + 10 - 1 ) : total_pages
    (start_page..end_page).to_a
  end
  
end