class RemoveAutomationScriptDeleteDependentToAutomationDriverConfigs < ActiveRecord::Migration
  def up
  	remove_foreign_key :automation_scripts, :name => "fk_as_adc"
  end

  def down
  	add_foreign_key :automation_scripts, :automation_driver_configs, :dependent => :delete, :name => "fk_as_adc"
  end
end
