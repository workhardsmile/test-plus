class AddScUsernameAndScPasswordToAutomationDriverConfigs < ActiveRecord::Migration
  def change
    add_column :automation_driver_configs, :sc_username, :string
    add_column :automation_driver_configs, :sc_password, :string
  end
end
