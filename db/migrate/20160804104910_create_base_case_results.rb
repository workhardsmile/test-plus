class CreateBaseCaseResults < ActiveRecord::Migration
  def change
    
    create_table :base_case_results do |t|
      t.string :automation_case_display_id
      t.string :case_name
      t.string :test_result
      t.text :triage_result#, :default => 'N/A'
      t.text :error_message#, :default => 'N/A'
      t.integer :automation_case_result_id
      t.references :base_script_result
      t.timestamps
    end
    
    add_index :base_case_results, [:automation_case_display_id,:case_name], :name => "idx_case_id_name_1"
  end
end
