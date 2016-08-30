# == Schema Information
#
# Table name: roles_users
#
#  role_id :integer
#  user_id :integer
#

class RolesUsers < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  
  acts_as_audited :protect => false
end
