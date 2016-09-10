class TempScheduleScriptsController < InheritedResources::Base
  #respond_to :js
  def get_schedule_scripts
    puts params[:salve_name],params['salve_name']
    schedule_scripts = TempScheduleScriptsHelper.get_schedule_scripts(params[:salve_name],params[:platforms],params[:project_names],params[:threads_number].to_i,params[:operation_system],request.remote_ip)
    render :json => schedule_scripts
  end
end
