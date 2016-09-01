class CreateBaseScriptResults < ActiveRecord::Migration
  def change
    create_table :base_script_results do |t|
      t.string :automation_script_name      
      t.string :environment
      t.string :browser
      t.integer :test_round_id
      t.string :test_result
      t.text :triage_result#, :default => 'N/A'
      t.string :os_type
      t.datetime :start_time
      t.datetime :end_time
      t.references :project
      t.timestamps
    end
    
    add_index :base_script_results, :automation_script_name, :name => "idx_bsr_name_1"
    add_index :base_script_results, :environment, :name => "idx_bsr_env_1"
    add_index :base_script_results, :browser, :name => "idx_bsr_browser_1"
 end
end
