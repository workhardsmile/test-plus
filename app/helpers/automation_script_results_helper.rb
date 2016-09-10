module AutomationScriptResultsHelper
  def AutomationScriptResultsHelper.delete_assign_script(script_result_id)
    ActiveRecord::Base.connection.execute("call update_script_result_status_by_script_result_id(#{script_result_id})")
  end
end
