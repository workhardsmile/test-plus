class MailNotifyGroup < ActiveRecord::Base
  has_and_belongs_to_many :mail_notify_settings
end
