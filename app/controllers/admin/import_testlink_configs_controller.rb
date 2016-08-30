class Admin::ImportTestlinkConfigsController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_import_testlink_configs_url}
  end

  def update
    update!{admin_import_testlink_configs_url}
  end

end


