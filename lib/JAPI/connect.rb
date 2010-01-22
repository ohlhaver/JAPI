#
# Module to make your application Jurnalo aware
# Authentication based on Jurnalo Central Login
#
class CASClient::Frameworks::Rails::GatewayFilter
  
  def self.logout( controller, service = nil )
    referer = service || controller.request.referer
    st = controller.session[ :cas_last_valid_ticket ]
    delete_service_session_lookup( st ) if st
    controller.send( :reset_session )
    controller.send( :redirect_to, client.logout_url( referer ) + "&gateway=1" )
  end
  
end

module JAPI
  
  module Connect
    
    def self.included( base )
      unless included_modules.include?( JAPI::Connect::InstanceMethods )
        base.send( :include, JAPI::Connect::AccountUrlHelper )
        base.send( :include, JAPI::Connect::InstanceMethods )
        base.send( :extend, JAPI::Connect::ClassMethods )
        JAPI::Connect::AccountUrlHelper.instance_methods.each{ |method| helper_method( method ) }
      end
    end
    
    module AccountUrlHelper
      
      def locale
        params[:locale]
      end
      
      def edition
        params[:edition]
      end
      
      def login_path
        CASClient::Frameworks::Rails::Filter.login_url( self )
      end
      
      def new_account_path( params = {} )
        { :host => JAPI::Config[:connect][:account_server], :controller => 'account', :locale => locale }.reverse_merge( params )
      end
      
      def account_path( params = {} )
        { :host => JAPI::Config[:connect][:account_server], :controller => 'account', :locale => locale }.reverse_merge( params )
      end
      
      def new_account_activation_path( params = {} )
        { :host => JAPI::Config[:connect][:account_server], :controller => 'account_activations', :action => 'new', :locale => locale }.reverse_merge( params )
      end
      
    end
    
    module InstanceMethods
      
      def set_locale
        params[:locale] = session[:locale] if params[:locale].blank? || !PreferenceOption.valid_locale?( params[:locale] )
        session[:locale] = params[:locale]
        session[:locale] ||= current_user.locale
        I18n.locale = session[:locale] || 'en'
        params[:locale] = session[:locale] unless params[:locale].blank?
      end
      
      def set_edition
        params[:edition] = session[:edition] if params[:edition].blank? || !PreferenceOption.valid_edition?( params[:edition] )
        session[:edition] = params[:edition]
        session[:edition] ||= current_user.edition
        params[:edition] = session[:edition] unless params[:edition].blank?
      end
      
      def logout
        CASClient::Frameworks::Rails::GatewayFilter.logout( self, JAPI::Config[:connect][:service] )
      end
      
      def require_no_user
        if logged_in?
          redirect_to account_path
          return false
        end
      end
      
      def logged_in?
        session && session[:cas_user_attrs]
      end
      
      def current_user
        @current_user
      end
      
      # Checks for session validation after 10.minutes
      def session_check_for_validation
        last_st = session.try( :[], :cas_last_valid_ticket )
        return unless last_st
        if request.get? && !request.xhr? && ( session[:revalidate].nil? || session[:revalidate] < Time.now )
          session[:cas_last_valid_ticket] = nil
          session[:revalidate] = JAPI::User.session_revalidation_timeout.from_now
        end
      end
      
      def set_current_user
        @current_user ||= JAPI::User.new( session[:cas_user_attributes] || {} )
      end
      
      def check_for_new_users
        if current_user.new_record?
          redirect_to new_account_path
          return false
        end
      end
      
      def store_location
        session[:return_to] = request.request_uri
      end
      
      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end
      
      def log_session_info
        logger.info "Start Session Info"
        session.each{ |k,v| 
          logger.info( "#{k}: #{v}" )
        }
        logger.info "End Session Info"
      end
      
      def redirect_to_activation_page_if_not_active
        unless current_user.active?
          redirect_to new_account_activation_path
          return false
        end
      end
      
      def cas_filter_allowed?
        true
      end
      
      def authenticate_using_cas_with_gateway
        CASClient::Frameworks::Rails::GatewayFilter.filter( self ) if cas_filter_allowed?
      end
      
      def authenticate_using_cas_without_gateway
        CASClient::Frameworks::Rails::Filter.filter( self ) if cas_filter_allowed?
      end
      
      protected( :authenticate_using_cas_without_gateway, :authenticate_using_cas_with_gateway, 
        :cas_filter_allowed?, :redirect_to_activation_page_if_not_active, :require_no_user, :current_user,
        :log_session_info, :redirect_back_or_default, :store_location, :check_for_new_users,
        :set_current_user, :session_check_for_validation, :set_locale, :set_edition )
      
    end
    
    module ClassMethods
      
      def japi_connect_login_required( options = {} )
        before_filter :session_check_for_validation
        if options[:only]
          before_filter :authenticate_using_cas_with_gateway,    :except => options[:only]
          before_filter :authenticate_using_cas_without_gateway, :only => options[:only]
        elsif options[:except]
          before_filter :authenticate_using_cas_with_gateway, :only => options[:except]
          before_filter :authenticate_using_cas_without_gateway, :except => options[:except]
        else
          before_filter :authenticate_using_cas_without_gateway
        end
        before_filter :set_current_user
        before_filter :set_locale
        before_filter :set_edition
        before_filter :check_for_new_users, options
        before_filter :redirect_to_activation_page_if_not_active, options
      end
      
    end
    
  end
end