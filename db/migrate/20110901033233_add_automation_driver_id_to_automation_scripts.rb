class AddAutomationDriverIdToAutomationScripts < ActiveRecord::Migration
  def change
    add_column :automation_scripts, :automation_driver_id, :integer
  end
end
