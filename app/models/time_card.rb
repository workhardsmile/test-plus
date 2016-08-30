# == Schema Information
#
# Table name: time_cards
#
#  id             :integer         not null, primary key
#  from           :date
#  to             :date
#  name           :string(255)
#  time_working   :integer
#  time_submitted :integer
#  time_approved  :integer
#  time_rejected  :integer
#  created_at     :datetime
#  updated_at     :datetime
#  week           :integer
#

class TimeCard < ActiveRecord::Base
  def amount
    time_working + time_submitted + time_approved + time_rejected
  end

  def css_class
    if time_approved > 0
      'green'
    elsif time_submitted > 0
      'yellow'
    else
      'pink'
    end
  end
end
