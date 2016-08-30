class CreateTestRounds < ActiveRecord::Migration
  def change
    create_table :test_rounds do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :state
      t.string :result
      t.string :test_object
      t.integer :pass
      t.integer :warning
      t.integer :failed
      t.integer :not_run
      t.float :pass_rate
      t.integer :duration
      t.string :triage_result
      t.references :test_environment
      t.references :project
      t.integer :creator_id
      t.references :test_suite

      t.timestamps
    end
    add_index :test_rounds, :test_environment_id, :name => "idx_tr_te"
    add_index :test_rounds, :project_id, :name => "idx_tr_p"
    add_index :test_rounds, :test_suite_id, :name => "idx_tr_ts"
    add_index :test_rounds, :creator_id, :name => "idx_tr_c"

    add_foreign_key :test_rounds, :test_environments, :dependent => :delete, :name => "fk_tr_te"
    add_foreign_key :test_rounds, :projects, :dependent => :delete, :name => "fk_tr_p"
    add_foreign_key :test_rounds, :test_suites, :dependent => :delete, :name => "fk_tr_ts"
  end
end
