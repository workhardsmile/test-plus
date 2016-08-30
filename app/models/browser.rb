# == Schema Information
#
# Table name: browsers
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  version    :string(255)
#  machine_id :integer
#  allowed    :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Browser < ActiveRecord::Base
  has_many :project_browser_configs
  has_many :projects, :through => :project_browser_configs

  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name

  def name_with_version
    "#{name}, #{version}"
  end
end
