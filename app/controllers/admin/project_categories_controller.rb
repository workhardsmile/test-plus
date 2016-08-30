class Admin::ProjectCategoriesController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

end
