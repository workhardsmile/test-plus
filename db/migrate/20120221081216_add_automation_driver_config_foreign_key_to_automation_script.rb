class AddAutomationDriverConfigForeignKeyToAutomationScript < ActiveRecord::Migration
  def change
    add_column :automation_scripts, :automation_driver_config_id, :integer
    add_index :automation_scripts, :automation_driver_config_id
    add_foreign_key :automation_scripts, :automation_driver_configs, :dependent => :delete, :name => "fk_as_adc"
  end
end
