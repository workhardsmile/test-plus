require "#{File.dirname(__FILE__)}/soapui_helper"

class RunSoapuiProcess

  def initialize(ruby_path, server_ip, command)
    @ruby_path = ruby_path
    @server_ip = server_ip
    @command_value = command
  end

  def start_run
    puts "start running SoapUI in process..."
    soapui_helper = SoapuiHelper.new(@ruby_path, @server_ip)
    soapui_helper.execute_soapui(@command_value)

  rescue Exception => e
    puts "Error: #{e.class}"
    puts "#{e}"
  ensure
    #qtp_helper.post_result @test_round_id, @test_round_name, "killed"
  end
end


RunSoapuiProcess.new(ARGV[0],ARGV[1],ARGV[2]).start_run
