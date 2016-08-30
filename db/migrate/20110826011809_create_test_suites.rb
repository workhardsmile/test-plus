class CreateTestSuites < ActiveRecord::Migration
  def change
    create_table :test_suites do |t|
      t.string :name
      t.string :status
      t.references :project
      t.integer :creator_id
      t.references :test_type

      t.timestamps
    end
    add_index :test_suites, :project_id, :name => "idx_ts_p"
    add_index :test_suites, :test_type_id, :name => "idx_ts_tt"
    add_foreign_key :test_suites, :projects, :dependent => :delete, :name => "fk_ts_p"
    add_foreign_key :test_suites, :test_types, :dependent => :delete, :name => "fk_ts_tt"
  end
end
