class CreateAutomationProgresses < ActiveRecord::Migration
  def change
    create_table :automation_progresses do |t|
      t.integer :project_id
      t.date :record_date
      t.integer :total_case
      t.integer :total_automated
      t.integer :not_candidate

      t.timestamps
    end
  end
end
