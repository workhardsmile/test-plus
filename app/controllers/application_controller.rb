class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :file => "#{Rails.root}/public/500.html", :status => 500, :layout => false
  end

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

end
