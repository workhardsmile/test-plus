class UserAbilityDefinition < ActiveRecord::Base
  belongs_to :user

  acts_as_audited :protect => false
  # acts_as_audited :protect => false, :only => [:create, :destroy]

  def self.create_for_user(user, ability, resource)
    user_ability_definition = UserAbilityDefinition.new
    user_ability_definition.user = user
    user_ability_definition.ability = ability
    user_ability_definition.resource = resource
    user_ability_definition.save
    user_ability_definition
  end
end
