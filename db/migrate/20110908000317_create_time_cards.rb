class CreateTimeCards < ActiveRecord::Migration
  def change
    create_table :time_cards do |t|
      t.date :from
      t.date :to
      t.string :name
      t.integer :time_working
      t.integer :time_submitted
      t.integer :time_approved
      t.integer :time_rejected

      t.timestamps
    end
  end
end
