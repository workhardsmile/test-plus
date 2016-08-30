# == Schema Information
#
# Table name: screen_shots
#
#  id                        :integer         not null, primary key
#  screen_shot_file_name     :string(255)
#  screen_shot_content_type  :string(255)
#  screen_shot_file_size     :integer
#  automation_case_result_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class ScreenShot < ActiveRecord::Base
  belongs_to :automation_case_result

  has_attached_file :screen_shot, :styles => { :large => "640x480", :medium => "300x300>", :thumb => "100x100>" }

end
