class CreateAutomationCases < ActiveRecord::Migration
  def change
    create_table :automation_cases do |t|
      t.string :name
      t.string :case_id
      t.string :version
      t.string :priority
      t.references :automation_script

      t.timestamps
    end
    add_index :automation_cases, :automation_script_id, :name => "idx_ac_as"
    add_foreign_key :automation_cases, :automation_scripts, :dependent => :delete, :name => "fk_ac_as"
  end
end
