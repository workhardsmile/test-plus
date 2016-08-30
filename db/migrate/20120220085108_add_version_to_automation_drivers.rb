class AddVersionToAutomationDrivers < ActiveRecord::Migration
  def change
    add_column :automation_drivers, :version, :string
  end
end
