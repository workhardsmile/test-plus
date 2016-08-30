class CreateJiraIssues < ActiveRecord::Migration
  def change
    create_table :jira_issues do |t|
      t.string :key
      t.string :status
      t.string :resolution
      t.datetime :jira_created
      t.datetime :jira_resolved
      t.string :priority
      t.string :severity
      t.string :issue_type
      t.string :environment_bug_was_found
      t.string :who_found
      t.string :market
      t.integer :planning_estimate_level_two
      t.string :components
      t.string :known_production_issue

      t.timestamps
    end
  end
end
