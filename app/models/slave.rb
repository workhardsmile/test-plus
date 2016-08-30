# == Schema Information
#
# Table name: slaves
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  ip_address   :string(255)
#  project_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  status       :string(255)
#

class Slave < ActiveRecord::Base
  has_one :operation_system_info
  has_many :capabilities
  has_many :slave_assignments
  has_many :automation_script_results, :through => :slave_assignments

  validates_presence_of :name, :project_name, :test_type, :priority
  validates_uniqueness_of :name, :case_sensitive => false, :message => " already exists."

  after_save :notify_updates
  after_destroy :notify_updates

  def free!
    self.status = "free"
    save
  end

  def offline!
    self.status = "offline"
    save
  end

  def status_with_active
    (self.status ? self.status : "") + (self.active ? "" : " / Inactive")
  end

  def notify_updates
    SlavesHelper.send_slave_to_update_list(self.id)
  end

  def project_name_arr
    project_name_arr = []
    if self.project_name and !self.project_name.blank?
      if self.project_name.include?(",")
        project_name_arr = self.project_name.split(",")
      elsif self.project_name.include?(";")
        project_name_arr = self.project_name.split(";")
      else
        project_name_arr << self.project_name
      end
    end
    project_name_arr.map {|project_name| project_name.strip}
  end

  def test_type_arr
    test_type_arr = []
    if self.test_type and !self.test_type.blank?
      if self.test_type.include?(",")
        test_type_arr = self.test_type.split(",")
      elsif self.test_type.include?(";")
        test_type_arr = self.test_type.split(";")
      else
        test_type_arr << self.test_type
      end
    end
    test_type_arr.map {|test_type| test_type.strip}
  end

  def capabilities_hash
    capabilities = self.capabilities.select(:name).map{|n| n.name}
    {:browsers => (Browser.all.map{|n| n.name} & capabilities).sort,
     :drivers => (AutomationDriver.all.map{|n| n.name} & capabilities).sort
     }
  end
end
