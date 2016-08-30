# == Schema Information
#
# Table name: project_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ProjectCategory < ActiveRecord::Base
  
  validates_presence_of :name
  validates_uniqueness_of :name, :message => " already exists."

  acts_as_audited :protect => false

  def has_associated_projects?
    Project.all.each do |project|
      return true if project.project_category_id == id
    end
    return false
  end

end
