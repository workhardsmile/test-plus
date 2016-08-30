class Admin::RolesController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    role = Role.new(:name => params[:role][:name])
    save_role!(role, params)

    if (role.errors.any?)
      @role = role
      render :new
    else 
      redirect_to admin_roles_path
    end
  end

  def update
    role = Role.find(params[:id])
    save_role!(role, params)

    if (role.errors.any?)
      @role = role
      render :edit
    else 
      redirect_to admin_roles_path
    end
  end

  private 
  def save_role!(role, params)

    role.name = params[:role][:name]

    rads = params["ability_definitions"]
    role.ability_definitions = Array.new
    if rads
      rad_array = rads.split("||")
      rad_array.shift
      rad_array.each do |rad|
        iterms = rad.split(" ")
        ability = iterms[1]
        resource = iterms[2]
        ability_definition = AbilityDefinition.find_by_ability_and_resource(ability, resource)
        ability_definition = AbilityDefinition.new(:ability => ability, :resource => resource) if ability_definition.nil?
        role.ability_definitions << ability_definition
      end
    end   

    role.save
  end

end
