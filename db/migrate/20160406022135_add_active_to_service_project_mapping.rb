class AddActiveToServiceProjectMapping < ActiveRecord::Migration
  def change
    add_column :service_project_mappings, :active, :boolean, :default => true
  end
end
