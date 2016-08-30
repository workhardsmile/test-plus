class AddTestSuiteIdToServiceTriggerRecords < ActiveRecord::Migration
  def change
    add_column :service_trigger_records, :test_suite_id, :integer
  end
end
