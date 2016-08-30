class CreateAutomationScripts < ActiveRecord::Migration
  def change
    create_table :automation_scripts do |t|
      t.string :name
      t.string :status
      t.string :version
      t.references :test_plan
      t.integer :owner_id
      t.references :project

      t.timestamps
    end
    add_index :automation_scripts, :test_plan_id, :name => "idx_as_tp"
    add_index :automation_scripts, :project_id, :name => "idx_as_p"

    add_foreign_key :automation_scripts, :test_plans, :dependent => :delete, :name => "fk_as_tp"
    add_foreign_key :automation_scripts, :projects, :dependent => :delete, :name => "fk_as_p"
  end
end
