class AddAssignedSlaveIdToTestRounds < ActiveRecord::Migration
  def change
    add_column :test_rounds, :assigned_slave_id, :integer,:null => false, :default => 0
  end
end
