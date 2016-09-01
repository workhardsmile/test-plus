module IssuesHelper
  def self.create_or_update_from_issue_params(issue_params)
    begin
      @issue = Issue.find_or_create_by_project_id_and_issue_display_id(issue_params[:project_id],issue_params[:issue_display_id])
      @issue.set_attributes_from_hash_params(issue_params)
      @issue.save!
      @issue
    rescue =>e
    #puts e
    false
    end
  end
  
  def self.find_issues_like_issue_display_id(issue_display_id,project_id,limit_num=10)
    return Issue.find(:all, :select=> "issue_display_id,issue_summary,issue_url,reporter", :limit => limit_num, :conditions => ["`issue_display_id` like ? and project_id=?","%#{issue_display_id}%",project_id])
  end
end
