class CreateServiceTriggerRecords < ActiveRecord::Migration
  def change
    create_table :service_trigger_records do |t|
      t.string :project_mapping_name
      t.integer :project_id
      t.integer :test_round_id
      t.string :status

      t.timestamps
    end
  end
end
