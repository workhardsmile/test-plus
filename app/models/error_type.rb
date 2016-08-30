class ErrorType < ActiveRecord::Base
  has_many :automation_script_results

  def self.pass_and_failed_options
    ErrorType.where("result_type in ('pass','failed')").order("result_type DESC, name ASC").map{|e| ["#{e.result_type.upcase} - #{e.name}", e.id]}
  end

  def self.pass_options
    ErrorType.where("result_type in ('pass')").order("name ASC").map{|e| ["#{e.result_type.upcase} - #{e.name}", e.id]}
  end

  def  self.all_options
    ErrorType.order("result_type DESC, name ASC").map{|e| ["#{e.result_type.upcase} - #{e.name}", e.id]}
  end
end
