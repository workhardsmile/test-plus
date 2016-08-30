class AddBrowserAndOsInfoToCiMappings < ActiveRecord::Migration
  def change
    add_column :ci_mappings, :browser_id, :integer
    add_column :ci_mappings, :operation_system_id, :integer
  end
end
