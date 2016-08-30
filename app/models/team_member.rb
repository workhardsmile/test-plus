# == Schema Information
#
# Table name: team_members
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  display_name :string(255)
#  email        :string(255)
#  cc_list      :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  manager      :string(255)
#  location     :string(255)
#  country      :string(255)
#  project      :string(255)
#  position     :string(255)
#  start_date   :date
#  turn_date    :date
#

class TeamMember < ActiveRecord::Base
end
