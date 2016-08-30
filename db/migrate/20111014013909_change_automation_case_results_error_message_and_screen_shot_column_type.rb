class ChangeAutomationCaseResultsErrorMessageAndScreenShotColumnType < ActiveRecord::Migration
  def up
    remove_foreign_key :automation_case_results, :name => "fk_acr_asr"
    remove_index :automation_case_results, :name => "idx_acr_asr"
    change_column :automation_case_results, :error_message, :text
    change_column :automation_case_results, :screen_shot, :text
    add_index :automation_case_results, :automation_script_result_id, :name => "idx_acr_asr"
    add_foreign_key :automation_case_results, :automation_script_results, :dependent => :delete, :name => "fk_acr_asr"
  end

  def down
    remove_foreign_key :automation_case_results, :name => "fk_acr_asr"
    remove_index :automation_case_results, :name => "idx_acr_asr"
    change_column :automation_case_results, :error_message, :string
    change_column :automation_case_results, :screen_shot, :string
    add_index :automation_case_results, :automation_script_result_id, :name => "idx_acr_asr"
    add_foreign_key :automation_case_results, :automation_script_results, :dependent => :delete, :name => "fk_acr_asr"
  end
end
