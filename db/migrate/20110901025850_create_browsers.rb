class CreateBrowsers < ActiveRecord::Migration
  def change
    create_table :browsers do |t|
      t.string :name
      t.string :version
      t.references :machine
      t.boolean :allowed

      t.timestamps
    end
    add_index :browsers, :machine_id, :name => "idx_b_m"
    add_foreign_key :browsers, :machines, :dependent => :delete, :name => "fk_b_m"
  end
end
