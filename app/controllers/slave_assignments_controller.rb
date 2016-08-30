class SlaveAssignmentsController < InheritedResources::Base
  respond_to :js
  
  def collection
    @slave = Slave.find(params[:slave_id])
    @search = @slave.slave_assignments.search(params[:search])
    @slave_assignments = @search.order('automation_script_result_id desc').page(params[:page]).per(15)
  end
  
end
