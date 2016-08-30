class AddTestLinkIdToTestCasesAndTcSteps < ActiveRecord::Migration
  def change
    add_column :test_cases, :test_link_id, :integer
    add_column :tc_steps, :test_link_id, :integer
  end
end
