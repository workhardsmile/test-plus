require "#{File.dirname(__FILE__)}/common_function"
require "logger"

class TimeCount
  attr_accessor :time
  attr_accessor :test_round_id
  attr_accessor :script_name
  attr_accessor :ruby_path
  attr_accessor :server_ip

  def initialize(time_value, test_round_id_value, script_name_value, ruby_path_value, server_ip_value)
    @logger = Logger.new('automation_client.log')

    @time = time_value
    @test_round_id = test_round_id_value
    @script_name = script_name_value
    @ruby_path = ruby_path_value
    @server_ip = server_ip_value
  end

  def time_count
    @logger.info "start monitoring automation tool crash or timeout (#{time})"
    time1 = Time.now
    while true
      sleep(10)
      time2 = Time.now
      if((time2.tv_sec-time1.tv_sec)>time)
        @logger.error "====> Timeout, killing QTP process..."
        kill_process "QTPro.exe"  # => Kill the QTPro.exe
        kill_process "QTAutomationAgent.exe"  # => Kill the QTAutomationAgent.exe
        break
      end
    end
  rescue Exception => e
    @logger.fatal "Error: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    post_result @test_round_id, @script_name, "killed"
  end
end

TimeCount.new(ARGV[0].to_i,ARGV[1],ARGV[2],ARGV[3],ARGV[4]).time_count
