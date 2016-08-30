class CreateServiceProjectMappings < ActiveRecord::Migration
  def change
    create_table :service_project_mappings do |t|
      t.string :service_name
      t.string :project_mapping_name
      t.integer :project_id

      t.timestamps
    end
  end
end
