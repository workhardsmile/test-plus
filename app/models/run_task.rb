# == Schema Information
#
# Table name: run_tasks
#
#  id         :integer         not null, primary key
#  command    :string(255)
#  priority   :string(255)
#  status     :string(255)
#  project    :string(255)
#  capability :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class RunTask < ActiveRecord::Base
  acts_as_audited :protect => false
end
