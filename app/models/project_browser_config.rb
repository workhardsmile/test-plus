# == Schema Information
#
# Table name: project_browser_configs
#
#  project_id :integer
#  browser_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class ProjectBrowserConfig < ActiveRecord::Base
  belongs_to :project
  belongs_to :browser
end
