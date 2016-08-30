class AbilityDefinition < ActiveRecord::Base
  # belongs_to :role
  has_and_belongs_to_many :roles
  # has_and_belongs_to_many :users
  belongs_to :ability_definitions_users
  
  acts_as_audited :protect => false
end
