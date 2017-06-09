class TempScheduleScriptsController < InheritedResources::Base
  #respond_to :js
  def get_schedule_scripts
    puts params[:salve_name],params['salve_name']
    slave = Slave.find_all_by_name(params[:salve_name])[0] rescue nil
    schedule_scripts = []
    unless slave.nil?
      params[:project_names] = params[:project_names].select{|p_name| slave.project_name.include?('*') or slave.project_name.include?(p_name)}
      schedule_scripts = TempScheduleScriptsHelper.get_schedule_scripts(params[:salve_name],params[:platforms],params[:project_names],params[:threads_number].to_i,params[:operation_system], (params[:ip] || request.remote_ip) )
    end
    render :json => schedule_scripts    
  end
end
