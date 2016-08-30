#require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))
require 'rubygems'
require 'eventmachine'
require 'yaml'
require "logger"
require 'active_record'
require 'active_support/core_ext/class/attribute_accessors'
require "#{File.dirname(__FILE__)}/../../app/models/run_task"
require "#{File.dirname(__FILE__)}/../../app/models/slave"
require "#{File.dirname(__FILE__)}/client_config"
require "#{File.dirname(__FILE__)}/server_conn"
require "#{File.dirname(__FILE__)}/run_task"

class Server
    def initialize
      @logger = Logger.new("#{File.dirname(__FILE__)}/../../log/farm_server.log")
    end

    def start
      trap('INT'){self.stop}
      trap('TERM'){self.stop}
      @logger.info "Starting farm server..."

      @signature = EventMachine.start_server('0.0.0.0', 9527, ServerConn) do |conn|
        ServerConn.connections << conn
      end
      @logger.info "Scheduling tasks every 1 minute..."
      puts "Server started. Scheduling tasks every 1 minute..."

      connect_to_db

      timer = EventMachine::PeriodicTimer.new(60) do
        if ServerConn.connections != nil
        @logger.info "Scheduling current connections length: #{ServerConn.connections.length}"
          ServerConn.connections.each do |c|
            @logger.info "Scheduling current connection custom_identify-#{c.custom_identify}"
            s= Slave.where(:name=>c.custom_identify).where("config<>?","").first
            if(s!=nil)
              @logger.info "send config info to client:\n#{s.config}"
              c.send_object s.config
              s.config = ""
              s.save
            else
              #s = Slave.joins(:capabilities).where(:name =>c.custom_identify,:capabilities => {:name => "qtp",:status => "free"}).first
              s = Slave.joins(:capabilities).where(:name =>c.custom_identify,:capabilities => {:status => "free",:allowed=>true}).first
              if s != nil
                @logger.info "Scheduling current slave: name-#{c.custom_identify}"
                #@logger.info "This slave prepare to run task: id-#{s.id} name-#{s.name} qtpstatus-#{s.capabilities.where(:name=>'qtp').first.status}"
                #task = RunTask.where(:status=>"ready").first
                freeCapabilities = s.capabilities.where(:status=>"free",:allowed=>true)
                freeCapabilitieNames = Array.new
                freeCapabilities.each do |freec|
                freeCapabilitieNames.push freec.name
                end
                task = RunTask.where(:status=>"ready",:market=>s.market_name.split(","),:capability=>freeCapabilitieNames).first
                if task != nil
                  @logger.info "Lunching task to slave-#{c.custom_identify}...#{task.command}"
                  rt = YAML::load(File.open("#{File.dirname(__FILE__)}/run-task.yml"))
                  rt.id = task.id
                  rt.command = task.command
                  rt.status = task.status
                  rt.priority = task.priority
                  c.send_object rt.to_yaml
                  task.status = "Scheduling"
                  task.save
                else
                  @logger.warn "The slave-#{c.custom_identify} is free. But it has not available capability or market to run task when this scheduling."
                end
              else
                @logger.info "The slave-#{c.custom_identify} is busy or no allowed capabilities when this scheduling."
              end
            end

          end
        end
      end

    rescue => e
      @logger.fatal e.message
      exit 1
    end

    def stop
      @logger.info "Server#stop"
      @logger.info "Server stopped"
      EventMachine.stop_server(@signature)
      EventMachine.stop
    end

    def connect_to_db
      db_ci = YAML::load(File.open("#{File.dirname(__FILE__)}/../../config/database.yml"))
      db = YAML::load(db_ci.to_yaml)
      ActiveRecord::Base.establish_connection(db["production"])
      #ActiveRecord::Base.default_timezone = Time.now.zone
      #ActiveRecord::Base.time_zone_aware_attributes = true
      ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/../../log/farm_server.log")
    end
end

#start server
#Daemons.run_proc('auto_server.rb') do
  EventMachine::run {
    Server.new.start
  }
#end