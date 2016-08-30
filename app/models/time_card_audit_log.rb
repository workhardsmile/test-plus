# == Schema Information
#
# Table name: time_card_audit_logs
#
#  id               :integer         not null, primary key
#  week             :integer
#  year             :integer
#  time_card_needed :float
#  time_card_actual :float
#  created_at       :datetime
#  updated_at       :datetime
#

class TimeCardAuditLog < ActiveRecord::Base
end
