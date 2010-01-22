class JAPI::User < JAPI::Model::Base
  
  cattr_accessor :session_revalidation_timeout
  self.session_revalidation_timeout ||= 10.minutes
  
  def active?
    active == 'true'
  end
  
  def locale
    PreferenceOption.locale( locale_id )
  end
  
  # Region and Language Combo
  def edition
    PreferenceOption.edition( edition_region_id, edition_locale_id )
  end
  
end