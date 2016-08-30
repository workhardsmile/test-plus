class CreateRunTasks < ActiveRecord::Migration
  def change
    create_table :run_tasks do |t|
      t.string :command
      t.string :priority
      t.string :status
      t.string :project
      t.string :capability

      t.timestamps
    end
  end
end
