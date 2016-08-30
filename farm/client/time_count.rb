require "qtp_helper"
require "logger"

class TimeCount
  attr_accessor :time
  attr_accessor :test_round_id
  attr_accessor :test_round_name
  attr_accessor :ruby_path
  attr_accessor :server_ip

  def initialize(time_value, test_round_id_value, test_round_name_value, ruby_path_value, server_ip_value)
    @time = time_value
    @test_round_id = test_round_id_value
    @test_round_name = test_round_name_value
    @ruby_path = ruby_path_value
    @server_ip = server_ip_value
    @logger = Logger.new('automation_client.log')
  end

  def time_count
    @logger.info "start monitoring QTP crash or timeout"
    qtp_helper = QTPHelper.new(@ruby_path, @server_ip, @logger)
    time1 = Time.now
    while true
      sleep(10)
      time2 = Time.now
      if((time2.tv_sec-time1.tv_sec)>time)
        @logger.error "====> Timeout, killing QTP process..."
        qtp_helper.kill_process "QTPro.exe"  # => Kill the QTPro.exe
        qtp_helper.kill_process "QTAutomationAgent.exe"  # => Kill the QTAutomationAgent.exe
        break
      end
    end
  rescue Exception => e
    @logger.fatal "Error: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end

TimeCount.new(ARGV[0].to_i,ARGV[1],ARGV[2],ARGV[3],ARGV[4]).time_count
