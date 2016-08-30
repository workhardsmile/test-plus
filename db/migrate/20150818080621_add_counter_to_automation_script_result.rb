class AddCounterToAutomationScriptResult < ActiveRecord::Migration
  def change
    add_column :automation_script_results, :counter, :integer, :default => 0
  end
end
