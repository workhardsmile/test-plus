class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :display_name
      t.string :email
      t.string :cc_list

      t.timestamps
    end
  end
end
