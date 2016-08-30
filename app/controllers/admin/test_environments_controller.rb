class Admin::TestEnvironmentsController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_test_environments_url}
  end

  def update
    update!{admin_test_environments_url}
  end

end
