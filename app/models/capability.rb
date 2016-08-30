# == Schema Information
#
# Table name: capabilities
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  version    :string(255)
#  slave_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Capability < ActiveRecord::Base
  belongs_to :slave
end
