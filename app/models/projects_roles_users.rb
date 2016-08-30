# == Schema Information
#
# Table name: projects_roles_users
#
#  projects_users_id :integer
#  user_id           :integer
#

class ProjectsRolesUsers < ActiveRecord::Base

  belongs_to :user
  belongs_to :projects_roles, :class_name => "ProjectsRoles", :foreign_key => "projects_roles_id"

  acts_as_audited :protect => false

end