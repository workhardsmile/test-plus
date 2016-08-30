# == Schema Information
#
# Table name: projects_roles
#
#  id         : integer
#  project_id :integer
#  role_id    :integer
#

class ProjectsRoles < ActiveRecord::Base

  belongs_to :project
  belongs_to :role

  has_and_belongs_to_many :user

  validates :role, :presence => true

  acts_as_audited :protect => false

end
