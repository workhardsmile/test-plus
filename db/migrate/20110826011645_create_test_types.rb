class CreateTestTypes < ActiveRecord::Migration
  def change
    create_table :test_types do |t|
      t.string :name
    end
  end
end
