class AddCommandAndDriverToSlaveAssignments < ActiveRecord::Migration
  def change
    add_column :slave_assignments, :driver, :string
  end
end
