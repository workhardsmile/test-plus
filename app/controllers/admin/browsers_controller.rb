class Admin::BrowsersController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_browsers_url}
  end

  def update
    update!{admin_browsers_url}
  end

end
