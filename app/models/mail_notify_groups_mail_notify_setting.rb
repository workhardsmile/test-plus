class MailNotifyGroupsMailNotifySetting < ActiveRecord::Base
  belongs_to :mail_notify_setting
  belongs_to :mail_notify_group
end
