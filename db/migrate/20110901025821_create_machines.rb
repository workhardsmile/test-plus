class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name
      t.string :os_name
      t.string :os_version
      t.references :slave

      t.timestamps
    end
    add_index :machines, :slave_id, :name => "idx_m_s"
    add_foreign_key :machines, :slaves, :column => 'slave_id', :dependent => :delete, :name => "fk_m_s"
  end
end
