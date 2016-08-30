class CreateAutomationCaseResults < ActiveRecord::Migration
  def change
    create_table :automation_case_results do |t|
      t.string :result
      t.string :error_message
      t.string :screen_shot
      t.string :priority
      t.references :automation_case
      t.references :automation_script_result

      t.timestamps
    end
    add_index :automation_case_results, :automation_case_id, :name => "idx_acr_ac"
    add_index :automation_case_results, :automation_script_result_id, :name => "idx_acr_asr"

    add_foreign_key :automation_case_results, :automation_cases, :dependent => :delete, :name => "fk_acr_ac"
    add_foreign_key :automation_case_results, :automation_script_results, :dependent => :delete, :name => "fk_acr_asr"
  end
end
