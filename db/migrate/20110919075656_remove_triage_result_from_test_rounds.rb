class RemoveTriageResultFromTestRounds < ActiveRecord::Migration
  def up
    remove_column :test_rounds, :triage_result
  end

  def down
    add_column :test_rounds, :triage_result, :string
  end
end
