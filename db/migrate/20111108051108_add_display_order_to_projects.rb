class AddDisplayOrderToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :display_order, :integer
  end
end
