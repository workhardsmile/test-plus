class RemoveDriverFromSlaveAssignments < ActiveRecord::Migration
  def up
  	remove_column :slave_assignments, :driver
  end

  def down
  	add_column :slave_assignments, :driver, :string
  end
end
