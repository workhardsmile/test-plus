class SlavesController < InheritedResources::Base
  layout 'no_sidebar'
  respond_to :js

  def collection
    @search = Slave.scoped.where("active <> :active or (active = :active and lower(status) = :status)", :active => false, :status => "busy").search(params[:search])
    @slave_count = @search.size
    @slaves = @search.page(params[:page]).order('status').per(15)
  end

  def resource
    @slave ||= Slave.find(params[:id])
    @search = @slave.slave_assignments.search(params[:search])
    @slave_assignments = @search.page(params[:page]).per(15)
  end

end
