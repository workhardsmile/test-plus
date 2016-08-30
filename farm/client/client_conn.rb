require 'rubygems'
require 'socket'
require 'eventmachine'
require 'yaml'
require 'resolv'
require 'logger'
require 'rbconfig'
require "win32/process"
require 'sys/proctable'
require '../server/client_config'
require '../server/run_task'
require 'client_helper'

class ClientConn < EM::Connection
  RUBY_PATH = File.join(Config::CONFIG["bindir"], Config::CONFIG["ruby_install_name"])
  AUTO_SERVER_YAML = YAML.load(File.open("#{File.dirname(__FILE__)}/autoserver.yml"))
  SERVER_IP_ADDRESS = AUTO_SERVER_YAML["server_ip"]
  CLIENT_CONFIG_PATH = "client-config.yml"
  CLIENT_ALLOWED_PATH = "client-allowed.yml"
  CAPABILITY_STATUS_COMMAND_PATH = "capability_status_command.yml"
  #use the object protocol
  include EM::P::ObjectProtocol
  include Sys

  #CoInitialize = Win32API.new('ole32', 'CoInitialize', 'P', 'L')

  def initialize(*args)
    super
    @logger = Logger.new('automation_client.log')
    @ch = ClientHelper.new(@logger)
    @machine_name = @ch.get_machine_name
    @os_hash = @ch.get_os_information
    @browser_hash = @ch.get_browser_information
    @ip_address = @ch.get_ip_address
  end

  def receive_object data
    @logger.info "recieve data from server\n#{data}\n"
    if data.start_with? '--- !ruby/object:RoundTask'
      command = YAML::load(data)
      command.status = "Running"
      send_object command.to_yaml

      @logger.info "send command running to server\n#{command.to_yaml}\n"
      #send_data_to_server("busy","unknown")
      send_capability_status("qtp","busy")

      command.status = "Complete"
      qtp_conmmand_content = command.to_yaml
      @logger.info "begin excuting qtp task after 45 seconds"
      EventMachine::add_timer(45){
        #aThread = Thread.new {
        qtpProcess = Process.create(:app_name =>"#{RUBY_PATH}  'run_qtp_process.rb' '#{RUBY_PATH}' '#{SERVER_IP_ADDRESS}' '#{command.command}'")
        puts "begin excuting qtp task\n"

        send_finished_information(qtpProcess.process_id,qtp_conmmand_content,"qtp")
            #qtp_helper = QTPHelper.new(RUBY_PATH, SERVER_IP_ADDRESS, @logger)
            #qtp_helper.execute_qtp(command.command)
        #}
        #aThread.run
          # qtp_helper = QTPHelper.new(RUBY_PATH, SERVER_IP_ADDRESS, @logger)
          # qtp_helper.execute_qtp(command.command)

          # @logger.info "finish excuting qtp task\n"
          # command.status = "Complete"
          # @logger.info "send command complete to server\n#{command.to_yaml}\n"
          # send_object command.to_yaml

          # send_data_to_server("free","unknown")
      }
      @logger.info "function return before timer."
    elsif data.start_with? '--- !ruby/object:ClientAllowed'
      config_allowed = YAML::load(data)
      allowedYaml = YAML::load(File.open(CLIENT_ALLOWED_PATH))
      allowedYaml.market.each_key{|key|
        if config_allowed.market.include? key
          allowedYaml.market[key] = true
        else
          allowedYaml.market[key] = false
        end
      }
      #browsers
      allowedYaml.browsers.each_key{|key|
        if config_allowed.browsers.include? key
          allowedYaml.browsers[key] = true
        else
          allowedYaml.browsers[key] = false
        end
      }
      #capabilities
      allowedYaml.capabilities.each_key{|key|
        if config_allowed.capabilities.include? key
          allowedYaml.capabilities[key] = true
        else
          allowedYaml.capabilities[key] = false
        end
      }

      #save
      @logger.info "saving #{CLIENT_ALLOWED_PATH} ...\n#{allowedYaml.to_yaml}"
      file_to_save = File.open(CLIENT_ALLOWED_PATH,"w")
      YAML::dump(allowedYaml,file_to_save)
      file_to_save.close
      @logger.info "save #{CLIENT_ALLOWED_PATH} finished"
    end
  end

  def send_finished_information(pid,command_content,capa_name)
    EventMachine::add_timer(10){
      break_flag = false
      ProcTable.ps{ |p|
        break_flag = true if p.pid==pid
      }
      #puts "flag = #{break_flag}"
      #break unless break_flag
      if break_flag
        send_finished_information(pid,command_content,capa_name)
      else
        @logger.info "finish excuting qtp task\n"

        @logger.info "send command complete to server\n#{command_content}\n"
        send_object command_content

        send_capability_status(capa_name,"free")
      end
    }
  end

  def send_capability_status(capa_name,capa_status)
    @logger.info "send_capability_status  #{capa_name}: #{capa_status} to server"
    ci = YAML::load(File.open(CAPABILITY_STATUS_COMMAND_PATH))
    ci.identity = "#{@machine_name}-#{@ip_address}"
    ci.name = capa_name
    ci.status = capa_status
    @logger.info "send data to server\n#{ci.to_yaml}\n"
    send_object ci.to_yaml
  end

  def send_init_data_to_server()
    @logger.info "send init data to server"
    ci = YAML::load(File.open(CLIENT_CONFIG_PATH))
    allowedYaml = YAML::load(File.open(CLIENT_ALLOWED_PATH))
    allowedYaml.market.delete_if {|key, value| value == false }
    allowedYaml.browsers.delete_if {|key, value| value == false }
    allowedYaml.capabilities.delete_if {|key, value| value == false }
    allowedBrowsersArr = allowedYaml.browsers.keys
    allowedCapabilitiesArr = allowedYaml.capabilities.keys
    if(allowedCapabilitiesArr.length==0 or allowedBrowsersArr.length==0)
      @logger.info "unbind called. At least one browser and capacibility are allowed."
      puts "unbind called. At least one browser and capacibility are allowed."
      EventMachine::stop_event_loop
      return
    end

    @logger.info "allowedYaml = \n#{allowedYaml.market.to_yaml}"
    ci.market = allowedYaml.market.keys.join(",")
    ci.identity = "#{@machine_name}-#{@ip_address}"
    ci.ip_address = @ch.get_ip_address
    ci.machine_info.name = @machine_name
    ci.machine_info.os = @os_hash[:name]
    ci.machine_info.version = @os_hash[:version]

    ci.machine_info.browsers_info[0].name = @browser_hash[:name]
    ci.machine_info.browsers_info[0].version = @browser_hash[:version]
    if allowedBrowsersArr.join(",").include? "Internet Explorer"
      ci.machine_info.browsers_info[0].allowed = true
    else
      ci.machine_info.browsers_info[0].allowed = false
    end

    firefox_version = @ch.get_fileversion_by_path(AUTO_SERVER_YAML["firefox_path"])
    if firefox_version!=""
      brNew = BrowserInfo.new
      brNew.name = "Mozilla Firefox"
      brNew.version = firefox_version
      if allowedBrowsersArr.join(",").include? brNew.name
        brNew.allowed = true
      else
        brNew.allowed = false
      end
      ci.machine_info.browsers_info.push brNew
    end

    #ci.capabilities[0].status = qtp_status
    #ci.capabilities[1].status = soapUI_status
    ci.capabilities.pop
    qtp_version = @ch.get_fileversion_by_path(AUTO_SERVER_YAML["qtp_path"])
    if qtp_version!=""
      brNew = CapabilityInfo.new
      brNew.name = "qtp"
      brNew.version = qtp_version
      brNew.status = "free"
      if allowedCapabilitiesArr.join(",").include? "qtp"
        brNew.allowed = true
      else
        brNew.allowed = false
      end
      ci.capabilities.push brNew
    end
    #soapui
    soapui_version = @ch.get_fileversion_for_soapui(AUTO_SERVER_YAML["soapui_path"])
    if soapui_version!=""
      brNew = CapabilityInfo.new
      brNew.name = "soapui"
      brNew.status = "free"
      brNew.version = soapui_version
      if allowedCapabilitiesArr.join(",").include? "soapui"
        brNew.allowed = true
      else
        brNew.allowed = false
      end
      ci.capabilities.push brNew
    end

    @logger.info "send data to server\n#{ci.to_yaml}\n"
    send_object ci.to_yaml
  end

  #@qtp_status free or busy
  #@soapUI_status free or busy
  def send_data_to_server(qtp_status,soapUI_status)
    @logger.info "send qtp_status = #{qtp_status}, soapUI_status = #{soapUI_status} to server"
    ci = YAML::load(File.open(CLIENT_CONFIG_PATH))
    ci.identity = "#{machine_name}-#{@ip_address}"
    ci.ip_address = @ch.get_ip_address
    ci.machine_info.name = @machine_name
    ci.machine_info.os = @os_hash[:name]
    ci.machine_info.version = @os_hash[:version]
    ci.machine_info.browsers_info[0].name = @browser_hash[:name]
    ci.machine_info.browsers_info[0].version = @browser_hash[:version]
    ci.capabilities[0].status = qtp_status
    ci.capabilities[1].status = soapUI_status
    @logger.info "send data to server\n#{ci.to_yaml}\n"
    send_object ci.to_yaml
  end

  def unbind
    @logger.info "unbind called. Server or client stop."
    puts "Client stop. A connection (either a server or client connection) is closed"
    EventMachine::stop_event_loop
  end
end

