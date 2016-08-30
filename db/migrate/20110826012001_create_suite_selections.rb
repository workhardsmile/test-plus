class CreateSuiteSelections < ActiveRecord::Migration
  def change
    create_table :suite_selections, :id => false do |t|
      t.references :test_suite
      t.references :automation_script

      t.timestamps
    end
    add_index :suite_selections, :test_suite_id, :name => "idx_ss_ts"
    add_index :suite_selections, :automation_script_id, :name => "idx_ss_as"

    add_foreign_key :suite_selections, :test_suites, :dependent => :delete, :name => "fk_ss_ts"
    add_foreign_key :suite_selections, :automation_scripts, :dependent => :delete, :name => "fk_ss_as"
  end
end
