# == Schema Information
#
# Table name: automation_drivers
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class AutomationDriver < ActiveRecord::Base
  has_many :automation_driver_configs

  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name

  def to_s
    self.name
  end

  def name_with_version
    self.name + " / " + self.version
  end

  def as_json(options={})
    {
      name: self.name,
      version: self.version
    }
  end
end
