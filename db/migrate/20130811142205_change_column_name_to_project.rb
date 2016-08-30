class ChangeColumnNameToProject < ActiveRecord::Migration
  def change
    rename_column :projects, :test_link_plan, :test_link_name
  end
end
