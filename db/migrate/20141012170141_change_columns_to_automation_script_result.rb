class ChangeColumnsToAutomationScriptResult < ActiveRecord::Migration
  def change
    add_column :automation_script_results, :error_type_id, :integer, :default => nil
    change_column :automation_script_results, :triage_result, :text
  end
end
