require "qtp_helper"
require "logger"

class RunQtpProcess

  def initialize(ruby_path_value, server_ip_value, command_value)
    # puts ruby_path_value
    # puts server_ip_value
    # puts command_value
    @ruby_path = ruby_path_value
    @server_ip = server_ip_value
    @command_value = command_value
    @logger = Logger.new('automation_client.log')
  end

  def start_run
    @logger.info "start running QTP in process..."
    qtp_helper = QTPHelper.new(@ruby_path, @server_ip, @logger)
    qtp_helper.execute_qtp(@command_value)

  rescue Exception => e
    @logger.fatal "Error: #{e.class}"
    @logger.fatal "#{e}"
  ensure
    #qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end


RunQtpProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
