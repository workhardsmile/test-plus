require "rubygems"
require "eventmachine"
require "#{File.dirname(__FILE__)}/server_conn"
require "#{File.dirname(__FILE__)}/../protocol/client_info"
require "#{File.dirname(__FILE__)}/../protocol/automation_command"
require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))

class Server
  attr_accessor :logger
  attr_accessor :connections

  def initialize
    @connections = {}
    @logger = Logger.new("#{Rails.root}/log/farm_server.log")
    logger.info 'Server#initialize'
  end

  def start
    trap('INT'){stop}
    trap('TERM'){stop}
    logger.info 'Server#start'

    Slave.all.each do |slave|
      slave.offline!
    end

    @signature = EventMachine.start_server('0.0.0.0', 9527, ServerConn) do |conn|
      logger.info 'Server#new_connection'
      conn.set_server(self)
    end

    EventMachine::PeriodicTimer.new(5) do
      # logger.debug "There're #{@connections.length} clients."
      SlaveAssignment.where(:status => 'pending').each do |sa|
        project = sa.automation_script_result.test_round.project
        driver = sa.driver.to_s

        slave = find_best_suite_slave(project, driver)

        if slave
          logger.debug "\n =========================================="
          logger.debug "Start schedule automation script result #{sa.automation_script_result.id} to slave #{slave.name}"
          logger.debug "Slave Assiginment --> #{sa.id}"
          connection = @connections[slave.id]
          command = TestPlus::Protocol::AutomationCommand.new
          command.driver = driver
          command.time_out_limit = sa.automation_script.time_out_limit.nil? ? 64*3600 : sa.automation_script.time_out_limit
          command.test_round_id = sa.test_round.id
          command.script_name = sa.automation_script.name
          command.test_environment = sa.test_round.test_environment.value
          command.test_type = sa.test_round.test_suite.test_type.name
          command.project_name = sa.test_round.project.name

          connection.send_object command
          logger.debug "\n send object ==> #{command}"
          
          slave.status = 'busy'
          slave.save
          sa.status = "running"
          sa.slave = slave
          sa.save
        else
          # logger.warn "No available slaves at this time, will wait for next scheduling round."
        end
      end
    end
  rescue => e
    logger.fatal e.message
  end

  # criteria to find a best suite slave:
  #   1. check whether there're 'free' and specific to a project slaves (based on project_name)
  #   2. If no, then check whether there're 'free' and not specific to any project slaves
  #   3. From the candidates selected from above, check whether there're slaves with automation script required automation driver installed (based on their capabilities)
  #   4. If yes, then use the first one as the best suite slave
  def find_best_suite_slave(project, driver)
    candidates = Slave.where("status = ? and project_name LIKE ?", "free", "%#{project.name}%")
    candidates = Slave.where(:status => 'free', :project_name => nil) if candidates.empty?
    slave = nil
    candidates.each do |candidate|
      unless candidate.capabilities.where(:name => driver.to_s).empty?
        slave = candidate
        break
      end
    end
    slave
  end

  def clear_slave_info(slave)
    slave.ip_address = ""
    slave.project_name = ""
    slave.operation_system_info.delete unless slave.operation_system_info.nil?
    slave.capabilities.delete_all
  end

  # called when a slave come online
  def add_or_update_client(client_info, connection)
    logger.info "Receive a client updating status request from #{connection.get_ip_address} for #{client_info.name}"
    slave = Slave.find_or_create_by_name(client_info.name)
    clear_slave_info(slave)

    slave.ip_address = connection.get_ip_address
    slave.project_name = client_info.project_name
    # todo: add more complicated situation handling:
    #   what if a client request add_or_update when there're already assignments in the database for it?
    slave.status = 'free'

    slave.operation_system_info = OperationSystemInfo.create({
      :name => client_info.operation_system.name,
      :version => client_info.operation_system.version
    })

    client_info.automation_drivers.each do |driver|
      slave.capabilities << Capability.create({:name => driver.name, :version => driver.version})
    end

    slave.save
    @connections[slave.id] = connection
    logger.info "Client #{client_info.name} status updated"
  end

  # called when a client connection closed
  def remove_client(conn)
    logger.info "A client connection closed."
    pair = @connections.rassoc(conn)

    if pair
      slave_id = pair[0]
      slave = Slave.find(slave_id)
      # reset_slave_assignments(slave_id)
      clear_slave_info(slave)
      slave.status = 'offline'
      slave.save
      @connections.delete slave_id
    end
  end
  
  def reset_slave_assignments(slave_id)
    SlaveAssignment.where(:status => 'running', :slave_id => slave_id).each do |sa|
      sa.status = "pending"
      sa.save
    end
  end

  def stop
    logger.info 'Server#stop'
    EventMachine.stop_server(@signature)
    EventMachine.stop
  end

end

EventMachine::run{
  Server.new.start
}
