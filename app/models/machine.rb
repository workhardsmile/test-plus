# == Schema Information
#
# Table name: machines
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  os_name    :string(255)
#  os_version :string(255)
#  slave_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Machine < ActiveRecord::Base

end
