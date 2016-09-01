class Issue < ActiveRecord::Base
  belongs_to :project
  has_many :issue_automation_scripts
  def set_attributes_from_hash_params(issue_params)
    self.project_id = issue_params[:project_id] unless issue_params[:project_id].nil?
    self.issue_display_id = issue_params[:issue_display_id] unless issue_params[:issue_display_id].nil?
    self.issue_summary = issue_params[:issue_summary] unless issue_params[:issue_summary].nil?
    self.issue_url = issue_params[:issue_url] unless issue_params[:issue_url].nil?
    self.reporter = issue_params[:reporter] unless issue_params[:reporter].nil?
  end
end
