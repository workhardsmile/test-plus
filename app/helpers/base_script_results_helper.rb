module BaseScriptResultsHelper
  class << self
    def sync_base_script_case_result(parameters)
      if parameters["projectId"] != nil && parameters["roundId"] != nil
        ActiveRecord::Base.connection.execute("call sync_base_script_result_proc(#{parameters["projectId"]},#{parameters["roundId"]},#{(parameters["isLast"].nil?||(parameters["isLast"].to_i==0))?0:1},@flag)") rescue false
        AutomationScriptResultsHelper.update_all_error_type_id
      end
    end
  end
end
