class JAPI::PreferenceOption < JAPI::Model::Base
  
  self.element_name = 'preferences'
  
  class Bijection
    
    attr_accessor :forward
    attr_accessor :reverse
    
    def initialize
      @forward ||= {}
      @reverse ||= {}
    end
    
    def []( key, direction = :forward )
      ( direction.to_sym == :reverse ) ? reverse[ key ] : forward[ key ]
    end
    
    def []=(key, value)
      forward[key] = value
      reverse[value] = key
    end
    
    def map( key )
      forward[ key ]
    end
    
    def reverse_map( value )
      reverse[ value ]
    end
    
    def empty?
      forward.empty?
    end
    
  end
  
  class << self 
    
    def category_options
      @@category_options ||= nil
      @@category_options = nil if @@category_options.try( :error )
      @@category_options ||= find( :all, :params => { :preference_id => 'category_id' } )
      @@category_options 
    end

    def time_span_options
      @@time_span_options ||= nil
      @@time_span_options = nil if @@time_span_options.try( :error )
      @@time_span_options ||= find( :all, :params => { :preference_id => 'time_span' } )
      @@time_span_options 
    end

    def video_pref_options
      @@video_pref_options ||= nil
      @@video_pref_options = nil if @@video_pref_options.try( :error )
      @@video_pref_options ||= find( :all, :params => { :preference_id => 'video' } )
      @@video_pref_options 
    end

    def opinion_pref_options
      @@opinion_pref_options ||= nil
      @@opinion_pref_options = nil if @@opinion_pref_options.try( :error )
      @@opinion_pref_options ||= find( :all, :params => { :preference_id => 'opinion' } )
      @@opinion_pref_options 
    end

    def blog_pref_options
      @@blog_pref_options ||= nil
      @@blog_pref_options = nil if @@blog_pref_options.try( :error )
      @@blog_pref_options ||= find( :all, :params => { :preference_id => 'blog' } )
      @@blog_pref_options 
    end
    
    def author_rating_options
      @@author_rating_options ||= nil
      @@author_rating_options = nil if @@author_rating_options.try( :error )
      @@author_rating_options ||= find( :all, :params => { :preference_id => 'author' } ).unshift( new( :name => 'prefs.val.nil', :code => :blank , :id => nil ) )
      @@author_rating_options
    end
    
    def source_rating_options
      @@source_rating_options ||= nil
      @@source_rating_options = nil if @@source_rating_options.try( :error )
      @@source_rating_options ||= find( :all, :params => { :preference_id => 'source' } ).unshift( new( :name => 'prefs.val.nil', :code => :blank , :id => nil ) )
      @@source_rating_options
    end
    
    def sort_criteria_options
      @@sort_criteria_options ||= nil
      @@sort_criteria_options = nil if @@sort_criteria_options.try( :error )
      @@sort_criteria_options ||= find( :all, :params => { :preference_id => 'sort_criteria' } )
      @@sort_criteria_options
    end

    def subscription_type_options
      @@subscription_type_options ||= nil
      @@subscription_type_options = nil if @@subscription_type_options.try( :error )
      @@subscription_type_options ||= find( :all, :params => { :preference_id => 'subscription_type' } )
      @@subscription_type_options
    end
    
    def language_options
      @@language_options ||= nil
      @@language_options = nil if @@language_options.try( :error )
      @@language_options ||= find( :all, :params => { :preference_id => 'language_id' } )
      @@language_options
    end
      
    def region_options
      @@region_options ||= nil
      @@region_options = nil if @@region_options.try( :error )
      @@region_options = find( :all, :params => { :preference_id => 'region_id' } )
      @@region_options
    end
  
    def language_bijection_map
      @@language_bijection_map ||= nil
      @@language_bijection_map = nil if @@language_bijection_map.try(:empty?)
      @@language_bijeciton_map ||= self.language_options.inject( Bijection.new ){ |map,record| map[ record.id.to_i ] = record.code.to_sym; map }
    end
  
    def region_bijection_map
      @@region_bijection_map ||= nil
      @@region_bijection_map = nil if @@region_bijection_map.try(:empty?)
      @@region_bijection_map ||= self.region_options.inject( Bijection.new ){ |map,record| map[ record.id.to_i] = record.code.to_s.downcase.to_sym; map }
    end
  
    #
    # edition 
    # JAPI::PreferenceOption.parse_edition( 'int-en' )
    # JAPI::PreferenceOption.parse_edition( 'int', 'en' )
    # JAPI::PreferenceOption.parse_edition( -1, 38 )
    #
    def parse_edition( region, language = :skipped )
      region, language = region.to_s.split('-') if language == :skipped
      region = case(region.to_s) when /\d+/ : region
      else region_id( region )
      end
      language = case(language.to_s) when /\d+/ : language
      else language_id( language )
      end
      OpenStruct.new( :region_id => region, :language_id => language, :region => region_code( region ), :locale => locale( language ) )
    end
  
    def edition( region, language )
      region = case( region.to_s ) when /\d+/ : region_code( region )
      else region end
      language = case( (language || 'en').to_s ) when /\d+/ : language_code( language )
      else language end
      region && language ? "#{region}-#{language}" : nil
    end
  
    def language_id( language_code )
      language_bijection_map[ language_code.to_sym, :reverse ] rescue nil
    end
  
    def language_code( language_id )
      language_bijection_map[ Integer(language_id) ] rescue nil
    end
  
    alias_method :locale_id, :language_id
    alias_method :locale, :language_code
  
    def region_id( region_code )
      region_bijection_map[ region_code.to_sym, :reverse ] rescue nil
    end
  
    def region_code( region_id )
      region_bijection_map[ Integer(region_id) ] rescue nil
    end
  
    def valid_locale?( locale )
      !locale_id( locale ).nil?
    end
  
    def valid_region?( region )
      !region_id( region ).nil?
    end
  
    def valid_edition?( edition )
      edition = parse_edition( edition )
      valid_locale?( edition.locale ) && valid_region?( edition.region )
    end
    
  end
  
end