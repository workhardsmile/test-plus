class AddTriageResultToAutomationCaseResults < ActiveRecord::Migration
  def change
    add_column :automation_case_results, :triage_result, :string, :default => 'N/A'
  end
end
