require 'rubygems'
require 'eventmachine'
require 'socket'
require 'active_record'
require 'active_support/core_ext/class/attribute_accessors'
require 'logger'
require 'yaml'

require "#{File.dirname(__FILE__)}/../../app/models/run_task"
require "#{File.dirname(__FILE__)}/../../app/models/slave"
require "#{File.dirname(__FILE__)}/../../app/models/browser"
require "#{File.dirname(__FILE__)}/../../app/models/capability"
require "#{File.dirname(__FILE__)}/../../app/models/machine"

class ServerConn  < EM::Connection
  cattr_accessor :logger
  cattr_accessor :connections
  attr_accessor :custom_identify
  include EM::P::ObjectProtocol
  self.connections = []
  self.logger = Logger.new("#{File.dirname(__FILE__)}/../../log/farm_server.log")

  def initialize(*args)
    super
    @custom_identify =""
  end

  def receive_object data
      logger.info "get data from slave:\n #{data}\n"
      connect_to_db
      if data.start_with? '--- keep hearting'
        handle_heart_beating
      elsif data.start_with? '--- !ruby/object:CapabilityStatusCommand'
        handle_capability_status_command(YAML::load(data))
      elsif data.start_with? '--- !ruby/object:RoundTask'
        deal_run_task(YAML::load(data))
      elsif data.start_with? '--- !ruby/object:ClientConfig'
        deal_client(YAML::load(data))
      end
      rescue Exception => e
        logger.error "handle received object from client failed..."
        logger.error e
    end

    def connect_to_db
      db_ci = YAML::load(File.open("#{File.dirname(__FILE__)}/database.yml"))
      db = YAML::load(db_ci.to_yaml)
      ActiveRecord::Base.establish_connection(db["production"])
      #ActiveRecord::Base.default_timezone = Time.now.zone
      #ActiveRecord::Base.time_zone_aware_attributes = true
      ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/../../log/farm_server.log")
    end

    def deal_run_task(data)
      logger.info "getting status #{data.status}"
      if data.status == "Running"
        rt = RunTask.find(data.id)
        rt.status = data.status
        rt.save
      elsif data.status == "Complete"
        RunTask.delete(data.id)
      end
    end

    def handle_heart_beating()
      logger.info "handle heart beating command:#{@custom_identify}"
      s = Slave.find_by_name(@custom_identify)
      if s != nil
        logger.info "update slave updated_at to now...#{Time.now}"
        s.created_at = Time.now - Time.now.gmt_offset
        s.save
        logger.info "update slave -#{@custom_identify} updated_at to now finished"
      else
        logger.error "Update slave updated_at failed. The salve doesn't exist by #{@custom_identify}"
      end
    end

    def handle_capability_status_command(data)
      logger.info "handle capability status command:\n #{data.name} #{data.status}\n"
      s = Slave.find_by_name(data.identity)
      if s != nil
        logger.info "update slave capability status..."
        for c in s.capabilities
          if c.name == data.name
            c.status = data.status
            c.save
            logger.info "update slave -#{data.identity} capability -#{data.name} status finished - #{data.status}"
          end
        end
      else
        logger.error "get wrong data of capability_status_command. The salve doesn't exist by #{data.identity}"
      end
    end

    def deal_client(data)
      @custom_identify = data.identity

      s = Slave.find_by_name(@custom_identify)
      if s == nil
      logger.info "creating slave info..."
        s = Slave.new
        s.name = data.identity
      end
      logger.info "updating slave info..."
      s.ip_address = data.ip_address
      s.market_name = data.market
      s.save

      logger.info "deleting machine, browser, capabilities info..."

      for m in s.machines
        for b in m.browsers
          b.destroy
        end
       m.destroy
      end

      for c in s.capabilities
       c.destroy
      end

      logger.info "deleted."
      logger.info "adding machine, browser, capabilities info..."

      machine = data.machine_info
      m = Machine.new
      m.name = machine.name
      m.os_name = machine.os
      m.os_version = machine.version
      m.slave = s
      m.save
      for browser in machine.browsers_info
        b = Browser.new
        b.name = browser.name
        b.version = browser.version
        b.allowed = browser.allowed
        b.machine = m
        b.save
      end

      for capability in data.capabilities
        if capability.status.to_s != "unknown"
          c = Capability.find_by_name_and_slave_id(capability.name,s.id)
          if c == nil
            c = Capability.new
            logger.info "create slave-#{s.name} capability - #{capability.name} capability"
          end
          c.name = capability.name
          c.version = capability.version
          c.allowed = capability.allowed
          logger.info "update slave-#{s.name} capability - #{capability.name} status - #{capability.status}"
          c.status = capability.status
          c.slave = s
          c.save
          logger.info "update slave-#{s.name} capability - #{capability.name} status- #{c.status} finished."
        end
      end

    end

    def unbind
      logger.info "Client unbind - signature= #{self.signature}"
      self.connections.delete self
    end



end
