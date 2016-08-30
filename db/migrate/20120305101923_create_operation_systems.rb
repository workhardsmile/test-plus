class CreateOperationSystems < ActiveRecord::Migration
  def change
    create_table :operation_systems do |t|
      t.string :name
      t.string :version

      t.timestamps
    end
  end
end
