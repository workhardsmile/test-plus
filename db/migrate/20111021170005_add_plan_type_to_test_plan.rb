class AddPlanTypeToTestPlan < ActiveRecord::Migration
  def change
    add_column :test_plans, :plan_type, :string
  end
end