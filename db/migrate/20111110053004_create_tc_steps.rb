class CreateTcSteps < ActiveRecord::Migration
  def change
    create_table :tc_steps do |t|
      t.integer :step_number
      t.text :step_action
      t.text :expected_result
      t.references :test_case

      t.timestamps
    end
    add_foreign_key :tc_steps, :test_cases, :dependent => :delete, :name => "fk_ts_tc"
  end
end
