class CreateSlaves < ActiveRecord::Migration
  def change
    create_table :slaves do |t|
      t.string :name
      t.string :ip_address
      t.string :project_name
      t.string :config

      t.timestamps
    end
  end
end
