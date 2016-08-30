class CreateOperationSystemInfos < ActiveRecord::Migration
  def change
    create_table :operation_system_infos do |t|
      t.string :name
      t.string :version
      t.references :slave

      t.timestamps
    end
    add_index :operation_system_infos, :slave_id, :name => "idx_osi_s"
    add_foreign_key :operation_system_infos, :slaves, :column => 'slave_id', :dependent => :delete, :name => "fk_osi_s"
  end
end
