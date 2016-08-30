class CreateTestEnvironments < ActiveRecord::Migration
  def change
    create_table :test_environments do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
