# == Schema Information
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  reset_password_token :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer         default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  display_name         :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise $authenticate_method, :rememberable, :trackable, :validatable

  # remove the :only because there's an issue with devise combined using :only. see https://github.com/collectiveidea/acts_as_audited/issues/55
  # acts_as_audited :except => [:password, :password_confirmation], :protect => false, :only => [:create, :destroy]
  acts_as_audited :except => [:password, :password_confirmation], :protect => false

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :display_name, :oracle_project_ids

  has_many :projects
  has_many :automation_scripts
  has_many :test_suites
  has_many :oracle_project_permissions
  has_many :oracle_projects, :through => :oracle_project_permissions
  has_many :user_ability_definitions

  has_and_belongs_to_many :projects_roles, :class_name => "ProjectsRoles"
  has_many :ability_definitions, :class_name => "AbilityDefinitionsUsers", :dependent => :destroy

  def self.automator
    User.find_by_email('automator@testplus.com')
  end

  def role?(role_name)
    if (role_name)
      roles = Role.find_all_by_name(role_name)
      if (roles && !roles.empty?) 
        role_ids = roles.map { |role| role.id }
        return !!self.projects_roles.find_by_role_id(role_ids)
      end
    end
    return
  end

  def update_role(role_id)
    role = Role.find(role_id)
    (self.roles.delete_all; self.roles << role) if role
    save
  end

  def update_oracle_projects(oracle_project_ids = [])
    self.oracle_projects.delete_all
    oracle_project_ids.each do |opi|
      oracle_project = OracleProject.find(opi)
      self.oracle_projects << oracle_project if oracle_project
    end
    save
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:email)
    where(conditions).where(["lower(email) = :value and active=1", {:value => login.strip.downcase}]).first
  end

  def self.find_or_create_default_by_email(strEmail)
    u = User.find_by_email(strEmail)
    if u.nil?
      names = strEmail.split("@").first.split(".")
      u = User.new(
        :email => strEmail,
        :display_name => "#{names.first.capitalize} #{names.last.capitalize}",
        :password => "111111"
      )
      qa_developer = Role.find_by_name("qa_developer")
      project_role = ProjectsRoles.find_by_role_id_and_project_id(qa_developer.id, nil)
      u.projects_roles << project_role
      # u.roles << Role.find_by_name("qa_developer")
      u.save
    end
    u
  end

  def ldap_before_save
    if self.email.nil? or self.display_name.nil?
      ldap_entry = Devise::LdapAdapter.get_ldap_entry(self.email)
      self.display_name = get_attr_from_ldap_entry(ldap_entry, "cn")
    end
  end

  def valid_ldap_authentication?(password)
    return self.active if super
  end

  private
  def get_attr_from_ldap_entry(ldap_entry, attribute)
    attr_value = nil
    if ldap_entry and ldap_entry.respond_to? attribute
      attr_value = ldap_entry.send(attribute)
      attr_value = attr_value.first if attr_value.is_a?(Array) and attr_value.count == 1
    end
  end

end
