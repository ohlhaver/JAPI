class Story < JAPI::Model::Base
  # From :authors, :sources, :advance
  #
  # find( :all, :from => :authors, :params => { :author_id => 1 } )
  # find( :all, :from => :sources, :params => { :source_id => 1 } )
  # find( :all, :from => :advance, :params => { :search_all => 'ram singla' } )
  #
end