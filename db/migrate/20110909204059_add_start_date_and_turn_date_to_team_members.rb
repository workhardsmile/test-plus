class AddStartDateAndTurnDateToTeamMembers < ActiveRecord::Migration
  def change
    add_column :team_members, :start_date, :date
    add_column :team_members, :turn_date, :date
  end
end
