class AddTestLinkPlanToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :test_link_plan, :string
  end
end
