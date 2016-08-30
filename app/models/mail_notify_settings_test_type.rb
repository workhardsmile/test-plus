class MailNotifySettingsTestType < ActiveRecord::Base
  belongs_to :mail_notify_setting
  belongs_to :test_type
end
