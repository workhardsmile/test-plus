class AddBrowserAndOperationSystemToSlaveAssignments < ActiveRecord::Migration
  def change
    add_column :slave_assignments, :browser_name, :string
    add_column :slave_assignments, :browser_version, :string
    add_column :slave_assignments, :operation_system_name, :string
    add_column :slave_assignments, :operation_system_version, :string
  end
end
