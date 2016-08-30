class RemoveAutomationDriverIdFromAutomationScript < ActiveRecord::Migration
  def up
  	remove_column :automation_scripts, :automation_driver_id
  end

  def down
  	add_column :automation_scripts, :automation_driver_id, :integer
  end
end
