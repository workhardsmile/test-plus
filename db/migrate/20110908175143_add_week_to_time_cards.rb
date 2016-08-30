class AddWeekToTimeCards < ActiveRecord::Migration
  def change
    add_column :time_cards, :week, :integer
  end
end
