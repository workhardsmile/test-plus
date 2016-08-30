class CreateCapabilities < ActiveRecord::Migration
  def change
    create_table :capabilities do |t|
      t.string :name
      t.string :status
      t.string :version
      t.references :slave
      t.boolean :allowed

      t.timestamps
    end
    add_index :capabilities, :slave_id, :name => "idx_c_s"
    add_foreign_key :capabilities, :slaves, :column => 'slave_id', :dependent => :delete, :name => "fk_c_s"
  end
end
