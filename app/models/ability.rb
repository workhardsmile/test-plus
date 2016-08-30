class Ability
  include CanCan::Ability
  alias_method :framework_can?, :can?

  def initialize(user, *extra_args)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    @user = user ||= User.new # guest user

    can :read, [TestRound, TestPlan, TestSuite, AutomationScript, AutomationCase, TestCase, AutomationScriptResult, AutomationCaseResult, AutomationDriverConfig, Project]


    if extra_args.nil? or extra_args.empty?
      set_role_ability_definitions(user.projects_roles)
      set_user_ability_definitions(user.ability_definitions)
    else
      set_role_ability_definitions(user.projects_roles.select {|pr| pr.project_id.nil? || pr.project_id == extra_args[0]})
      set_user_ability_definitions(user.ability_definitions.select {|ad| ad.project_id.nil? || ad.project_id == extra_args[0]})
    end

    set_special_ability_definitions
  end

  def can?(action, subject, *extra_args)

    unless extra_args.nil? and extra_args.empty?
      extra_arg0 = extra_args[0]
      if extra_arg0.respond_to? :has_key? and extra_arg0.has_key?(:project_id)
        project_id = extra_arg0[:project_id]
        extra_args.shift
      end
    end

    if project_id.nil?
      return framework_can? action, subject, extra_args
    else
      @project_ability_cache = Hash.new if @project_ability_cache.nil?
      if @project_ability_cache.has_key? project_id
        project_ability = @project_ability_cache[project_id]
      else
        project_ability = Ability.new(@user, project_id)
        @project_ability_cache[project_id] = project_ability
      end
      return project_ability.can? action, subject
    end

  end  

  private

  def set_role_ability_definitions(projects_roles)
    projects_roles.each do |project_role|
      role = project_role.role
      if role.name == 'admin'
        can :manage, :all
      else
        role.ability_definitions.each do |ad|
          can ad.ability.to_sym, ad.resource.constantize
        end
      end
    end
  end

  def set_user_ability_definitions(ability_definitions_users)
    ability_definitions_users.each do |uad|
      can uad.ability_definition.ability.to_sym, uad.ability_definition.resource.constantize
    end
  end

  def set_special_ability_definitions
    
    alias_action :search_automation_script, :to => :read
    cannot :update_display_order, Project if !@user.role? :admin
  end

end
