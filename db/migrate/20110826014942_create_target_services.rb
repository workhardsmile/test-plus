class CreateTargetServices < ActiveRecord::Migration
  def change
    create_table :target_services do |t|
      t.string :name
      t.string :version
      t.references :automation_script_result

      t.timestamps
    end
    add_index :target_services, :automation_script_result_id, :name => "idx_ts_asr"
    add_foreign_key :target_services, :automation_script_results, :dependent => :delete, :name => "fk_ts_asr"
  end
end
