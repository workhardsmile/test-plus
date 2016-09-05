class AddDashboardNameToProject < ActiveRecord::Migration
  def change
    add_column :projects, :dashboard_name, :string
  end
end
