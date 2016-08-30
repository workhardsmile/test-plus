class AddBrowserAndOperationSystemToTestRounds < ActiveRecord::Migration
  def change
    add_column :test_rounds, :browser_id, :integer
    add_column :test_rounds, :operation_system_id, :integer
    add_index :test_rounds, :browser_id, :name => 'idx_tr_b'
    add_index :test_rounds, :operation_system_id, :name => 'idx_tr_os'
    add_foreign_key :test_rounds, :browsers, :dependent => :delete, :name => 'fk_tr_b'
    add_foreign_key :test_rounds, :operation_systems, :dependent => :delete, :name => 'fk_tr_os'
  end
end
