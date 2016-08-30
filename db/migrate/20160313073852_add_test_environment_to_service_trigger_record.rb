class AddTestEnvironmentToServiceTriggerRecord < ActiveRecord::Migration
  def change
    add_column :service_trigger_records, :test_environment, :string
  end
end
