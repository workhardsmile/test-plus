class AddTriageResultToAutomationScriptResult < ActiveRecord::Migration
  def change
    add_column :automation_script_results, :triage_result, :string
  end
end
