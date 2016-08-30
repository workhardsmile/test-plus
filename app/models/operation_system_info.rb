# == Schema Information
#
# Table name: operation_system_infos
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  version    :string(255)
#  slave_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class OperationSystemInfo < ActiveRecord::Base
  belongs_to :slave
end
