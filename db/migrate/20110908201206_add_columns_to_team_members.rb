class AddColumnsToTeamMembers < ActiveRecord::Migration
  def change
    add_column :team_members, :manager, :string
    add_column :team_members, :location, :string
    add_column :team_members, :country, :string
    add_column :team_members, :project, :string
    add_column :team_members, :position, :string
  end
end
