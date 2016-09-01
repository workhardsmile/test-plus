class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :project
      t.string :issue_display_id
      t.string :issue_summary
      t.string :issue_url
      t.string :reporter

      t.timestamps
    end
    add_index :issues, :issue_display_id, :name => "idx_issue_id_1"
  end
end
