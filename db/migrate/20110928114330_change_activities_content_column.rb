class ChangeActivitiesContentColumn < ActiveRecord::Migration
  def up
    change_column :activities, :content, :text
  end

  def down
    change_column :activities, :content, :string
  end
end
