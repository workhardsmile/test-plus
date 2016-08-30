class RemoveAutomationVersionFromTestCases < ActiveRecord::Migration
  def up
    remove_column :test_cases, :automation_version
  end

  def down
    add_column :test_cases, :automation_version, :string
  end
end
