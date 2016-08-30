class CreateSlaveAssignments < ActiveRecord::Migration
  def change
    create_table :slave_assignments do |t|
      t.references :automation_script_result
      t.references :slave
      t.string :status

      t.timestamps
    end
    add_index :slave_assignments, :automation_script_result_id, :name => "idx_sa_asr"
    add_index :slave_assignments, :slave_id, :name => "idx_sa_s"
    add_foreign_key :slave_assignments, :automation_script_results, :dependent => :delete, :name => "fk_sa_asr"
    add_foreign_key :slave_assignments, :slaves, :column => 'slave_id', :dependent => :delete, :name => "fk_sa_s"
  end
end
