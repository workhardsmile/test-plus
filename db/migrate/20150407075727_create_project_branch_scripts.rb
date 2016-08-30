class CreateProjectBranchScripts < ActiveRecord::Migration
  def change
    create_table :project_branch_scripts do |t|
      t.integer :project_id
      t.string :automation_script_name
      t.string :branch_name

      t.timestamps
    end
  end
end
