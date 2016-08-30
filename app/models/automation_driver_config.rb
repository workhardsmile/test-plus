class AutomationDriverConfig < ActiveRecord::Base
  belongs_to :project
  belongs_to :automation_driver
  has_many :automation_scripts

  validates_presence_of :name, :automation_driver, :source_control, :source_paths, :script_main_path
  validates_uniqueness_of :name, :scope => :project_id

  def as_json(options={})
    {
      extra_parameters: self.extra_parameters,
      source_paths: self.source_paths
    }
  end

  def source_paths_as_array()
    source_paths_arr = Array.new
    if source_paths and !source_paths.empty?
      source_paths_arr = JSON.parse(source_paths)
    end

    source_paths_arr
  end

end
