# == Schema Information
#
# Table name: test_types
#
#  id   :integer         not null, primary key
#  name :string(255)
#

class TestType < ActiveRecord::Base
  has_many :test_suites
  has_and_belongs_to_many :mail_notify_settings
  acts_as_audited :protect => false
  # acts_as_audited :protect => false, :only => [:create, :destroy]
end
