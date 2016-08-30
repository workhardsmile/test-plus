class CreateAutomationDrivers < ActiveRecord::Migration
  def change
    create_table :automation_drivers do |t|
      t.string :name

      t.timestamps
    end
  end
end
