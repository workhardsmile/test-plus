class AddTitleToJiraIssues < ActiveRecord::Migration
  ############################################################
  # Database migration targeting the SecondBase!
  # Generated using: rails generator secondbase:migration [MigrationName]
  
  def change
    add_column :jiraissue, :summary, :string
    add_column :fnd_jira_issues, :summary, :string
  end
  
end
