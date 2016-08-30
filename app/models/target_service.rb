# == Schema Information
#
# Table name: target_services
#
#  id                          :integer         not null, primary key
#  name                        :string(255)
#  version                     :string(255)
#  automation_script_result_id :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

class TargetService < ActiveRecord::Base
  belongs_to :automation_script_result

  def to_s
    "#{self.name} #{self.version}"
  end

  def self.create_services_for_automation_script_result(services, automation_script_result)
    services = ([]<<services).flatten
    services.each do |s|
      target_service = TargetService.create({
        :name => s['name'],
        :version => s['version']
      })
      target_service.automation_script_result = automation_script_result
      target_service.save
    end
  end
end
