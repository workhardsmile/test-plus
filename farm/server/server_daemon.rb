require 'rubygems'
require 'active_support/core_ext/class/attribute_accessors'
require 'daemons'
require 'server/logger'
require 'server/server'
require 'server/connection'

module AutoCenter
  class ServerDaemon
    cattr_accessor :logger
    self.logger = Logger.new(File.join(Rails.root, 'log', 'farm_server.log'))

    def initialize
      logger.info "\n\nServerDaemon#initialize"
      @monitor = false
    end

    def daemonize
      dir = "#{Rails.root}/tmp/pids"
      Dir.mkdir(dir) unless File.exists?(dir)

      run_process(dir)
    end

    def run_process(dir)
      Daemons.run_proc('automation_server', :dir => dir, :dir_mode => :normal, :monitor => @monitor) do |args|
        run
      end
    end

    def run
      EventMachine::run {
        AutoCenter::Server.logger = Logger.new(File.join(Rails.root, 'log', 'farm_server.log'))
        AutoCenter::Connection.logger = Logger.new(File.join(Rails.root, 'log', 'farm_server.log'))
        AutoCenter::Server.new.start
      }
    rescue => e
      tlogger = Logger.new(File.join(Rails.root, 'log', 'automation_server.log'))
      tlogger.fatal e.message
      exit 1
    end
  end
end

