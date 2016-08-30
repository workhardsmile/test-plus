require "rubygems"
require "eventmachine"

module TestPlus
  module Protocol
    class AutomationCommand
      attr_accessor :driver
      attr_accessor :time_out_limit
      attr_accessor :test_round_id
      attr_accessor :script_name
      attr_accessor :test_environment
      attr_accessor :test_type
      attr_accessor :project_name
      
      def execute(connection)
        
        # EventMachine::add_timer(45){
        require "win32/process"
        require "rbconfig"
          ruby_path = File.join(Config::CONFIG["bindir"], Config::CONFIG["ruby_install_name"])
          driver_file = "run_#{driver}_process.rb"
          
          server_ip = connection.get_ip_address
          command_line = "auto-run :driver=>#{driver} :project=>#{project_name} :test_round_id=>#{test_round_id} :test_env=>#{test_environment} :test_type=>#{test_type} :script_name=>#{script_name} :time_out_limit=>#{time_out_limit}"
        
          require "#{File.dirname(__FILE__)}/run_#{driver}_process"
  
          
          case driver
            when "qtp"
              process_obj = RunQtpProcess.new(ruby_path,server_ip,command_line)
            when "soapui"
              process_obj = RunSoapuiProcess.new(ruby_path,server_ip,command_line)
            when "rspec"
              process_obj = RunRspecProcess.new(ruby_path,server_ip,command_line)
            when "junit"
              process_obj = RunJunitProcess.new(ruby_path,server_ip,command_line)
            when "testng"
              process_obj = RunTestngProcess.new(ruby_path,server_ip,command_line)
            else
              puts "There no such process: run_#{driver}_process"
              return
          end
          process_obj.start_run
          
          # automation_process = Process.create(:app_name =>"#{ruby_path} '#{File.dirname(__FILE__)}/#{driver_file}' '#{ruby_path}' '#{server_ip}' '#{command_line}'")
          
          # qtpProcess = Process.create(:app_name =>"#{RUBY_PATH}  'run_#{driver}_process.rb' '#{RUBY_PATH}' '#{SERVER_IP_ADDRESS}' '#{command}'")
        # }
      end
    end
  end
end
