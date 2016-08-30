class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.string :name
      t.string :case_id
      t.string :version
      t.string :automation_version
      t.string :automated_status
      t.string :priority
      t.references :test_plan

      t.timestamps
    end
    add_index :test_cases, :test_plan_id, :name => "idx_tc_tp"
    add_foreign_key :test_cases, :test_plans, :dependent => :delete, :name => "fk_tc_tp"
  end
end
