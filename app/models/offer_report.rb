class OfferReport < ActiveRecord::Base
  validates :result, :market, :offer_type, :timestamp, presence: true
  validates :result, :inclusion => {:in => %w(pass failed)}
end
