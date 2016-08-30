class AbilityDefinitionsUsers < ActiveRecord::Base

  belongs_to :user
  belongs_to :ability_definition
  belongs_to :project

  acts_as_audited :protect => false
end