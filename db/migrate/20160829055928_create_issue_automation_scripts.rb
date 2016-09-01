class CreateIssueAutomationScripts < ActiveRecord::Migration
  def change
    create_table :issue_automation_scripts do |t|      
      t.references :issue
      t.references :project
      t.string :automation_script_name
      t.string :found_case_id
      t.string :found_environment
      t.string :found_browser
      t.string :found_os_type

      t.timestamps
    end
    
    add_index :issue_automation_scripts, :automation_script_name, :name => "idx_ias_script_1"
    add_index :issue_automation_scripts, :found_case_id, :name => "idx_ias_case_id_1"    
    add_index :issue_automation_scripts, :found_environment, :name => "idx_ias_env_1"
    add_index :issue_automation_scripts, :found_browser, :name => "idx_ias_browser_1" 
    add_index :issue_automation_scripts, :found_os_type, :name => "idx_ias_os_1"
  end
end
