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
    
  end
  
  class << self 
    
    def language_options
      @@language_options = find( :all, :params => { :preference_id => 'language_id' } ) if @@language_options.blank?
      @@language_options
    end
  
    def region_options
      @@region_options = find( :all, :params => { :preference_id => 'region_id' } ) if @@region_options.blank?
      @@region_options
    end
  
    def language_bijection_map
      @@language_bijeciton_map ||= self.language_options.inject( Bijection.new ){ |map,record| map[ record.id.to_i ] = record.code.to_sym; map }
    end
  
    def region_bijection_map
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
      OpenStruct.new( :region_id => region, :language_id => language_id )
    end
  
    def edition( region, language )
      region = case( region.to_s ) when /\d+/ : region_code( region )
      else region end
      language = case( (language || 'en').to_s ) when /\d+/ : language_code( language )
      else language end
      region && language ? "#{region}-#{language}" : nil
    end
  
    def language_id( langauage_code )
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
      region_bijection_map[ Integer(region_id), :reverse ] rescue nil
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