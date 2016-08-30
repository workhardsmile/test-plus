class AddServerLogToAutomationCaseResults < ActiveRecord::Migration
  def change
    add_column :automation_case_results, :server_log, :text
  end
end
