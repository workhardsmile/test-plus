class CreateAutomationDriverConfigs < ActiveRecord::Migration
  def change
    create_table :automation_driver_configs do |t|
      t.belongs_to :project
      t.belongs_to :automation_driver
      t.string :name
      t.string :source_control
      t.text :extra_parameters
      t.text :source_paths
      t.text :script_main_path

      t.timestamps
    end
    add_index :automation_driver_configs, :project_id
    add_index :automation_driver_configs, :automation_driver_id
    add_foreign_key :automation_driver_configs, :projects, :dependent => :delete, :name => "fk_adc_p"
    add_foreign_key :automation_driver_configs, :automation_drivers, :dependent => :delete, :name => "fk_adc_ad"
  end
end
