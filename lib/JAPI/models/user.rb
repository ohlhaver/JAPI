class JAPI::User < JAPI::Model::Base
  
  cattr_accessor :session_revalidation_timeout
  self.session_revalidation_timeout ||= 10.minutes
  
  def home_blocks_order
    user_id = new_record? ? 'default' : self.id 
    return @home_blocks_order if @home_blocks_order
    prefs = JAPI::HomeDisplayPreference.find( :all, :params => { :user_id => user_id } )
    @home_blocks_order = prefs.collect{ |pref| pref.element.code }
  end
  
  def nav_blocks_order
    @nav_blocks_order ||= ( new_record? ? home_blocks_order : ( home_blocks_order + self.class.new.home_blocks_order ).uniq )
  end
  
  def home_blocks( edition = nil )
    blocks = ActiveSupport::OrderedHash.new
    edition ||= JAPI::PreferenceOption.parse_edition( self.edition || 'int-en' )
    home_blocks_order.inject( blocks ){ |opts, pref|
      case( pref ) when :top_stories
        block[:top_stories] = nil
      when :cluster_groups
        blocks[:sections] = JAPI::ClusterGroup.find( :all, :params => { :user_id => self.id, :cluster_group_id => 'all', 
          :region_id => edition.region_id, :language_id => edition.language_id } )
      when :top_authors
        blocks[:top_authors] = [ JAPI::Story.find( :all, :from => :authors, :params => { :author_ids => :top, :preview => 1, :user_id => self.id,
          :language_id => edition.language_id } ) ]
      when :my_authors
        blocks[:my_authors] = [ JAPI::Story.find( :all, :from => :authors, :params => { :author_ids => :all, :user_id => self.id, :preview => 1, 
          :language_id => edition.language_id } ) ] unless self.id.blank?
      when :my_topics
        blocks[:topics] = JAPI::Topic.find( :all, :params => { :topic_id => :all, :user_id => self.id } ) unless self.id.blank?
      end
    }
    if blocks[:sections].blank?
      blocks[:top_stories] = [ JAPI::ClusterGroup.find( :all, :params => { :user_id => user_id, :cluster_id => 'top', :preview => 1, :language_id => edition.language_id } ) ]
    else
      blocks[:top_stories] = [ blocks[:sections].shift ]
    end if blocks.key?( :top_stories )
    return blocks
  end
  
  def navigation_links( edition = nil )
    user_id = new_record? ? 'default' : self.id 
    options = ActiveSupport::OrderedHash.new
    edition ||= JAPI::PreferenceOption.parse_edition( self.edition || 'int-en' )
    nav_blocks_order.inject(options){ |opts, pref|
      case( pref ) when :top_stories_cluster_group
        opts[ :top_stories ] = JAPI::NavigationLink.new( :id => 'top', :name => 'Top Stories', :type => 'cluster_group' )
      when :cluster_groups 
        opts[ :sections ] = JAPI::HomeClusterPreference.find( :all, :params => { :user_id => user_id, 
          :language_id => edition.language_id, :region_id => edition.region_id } ).collect{ |pref| 
          JAPI::NavigationLink.new( :id => pref.cluster_group.id , :name => pref.cluster_group.name , :type => 'cluster_group' )
        }
        opts[ :add_section ] = JAPI::NavigationLink.new( :name => 'Add Section', :type => 'new_cluster_group', :remote => true )
      when :my_topics
        options[ :topics ] = JAPI::TopicPreference.find( :all, :params => { :user_id => user_id } ).collect do |pref|
          JAPI::NavigationLink.new( :id => pref.id, :name => pref.name, :translate => false, :type => 'topic' )
        end
        options[ :add_topic ] = JAPI::NavigationLink.new( :name => 'Add Topic', :type => 'new_topic', :remote => true )
        options[ :my_topics ] = JAPI::NavigationLink.new( :name => 'My Topics', :type => 'my_topics', :remote => true )
      when :top_authors
        options[ :top_authors ] = JAPI::NavigationLink.new( :name => 'Top Authors', :type => 'top_authors' )
      when :my_authors
        options[ :my_authors ] = JAPI::NavigationLink.new( :name => 'My Authors', :type => 'my_authors' )
      end
      options
    }
    return options
  end
  
  def active?
    active == true rescue true
  end
  
  # Interface Language
  def locale
    JAPI::PreferenceOption.locale( locale_id ) rescue nil
  end
  
  # Region and Language Combo
  def edition
    JAPI::PreferenceOption.edition( edition_region_id, edition_locale_id ) rescue nil
  end
  
end