class AddCounterToTestRound < ActiveRecord::Migration
  def change
    add_column :test_rounds, :counter, :integer, :default => 1
  end
end
