# run with: god -c /path/to/xxxx.god -D
#
# This is the actual config file used to keep testplus farm server running.
RAILS_ENV = "production"
FARM_SERVER_ROOT = "/home/active/farm_server"

God.watch do |w|
  w.name = "farm-server-watcher"
  w.log = "#{FARM_SERVER_ROOT}/log/god-farm-server.log"
  w.interval = 30.seconds # default
  w.start = "cd #{FARM_SERVER_ROOT}; rvm use ruby-1.9.3-p429@rails31; RAILS_ENV=#{RAILS_ENV} ruby server_control.rb start"
  w.stop = "cd #{FARM_SERVER_ROOT}; rvm use ruby-1.9.3-p429@rails31; RAILS_ENV=#{RAILS_ENV} ruby server_control.rb stop"
  w.restart = "cd #{FARM_SERVER_ROOT}; rvm use ruby-1.9.3-p429@rails31; RAILS_ENV=#{RAILS_ENV} ruby server_control.rb restart"
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds
  w.pid_file = "#{FARM_SERVER_ROOT}/server.rb.pid"

  w.behavior(:clean_pid_file)

  God::Contacts::Email.defaults do |d|
    d.from_email = 'testplus@active.com'
    d.from_name = 'TestPlus farm server monitoring'
    d.delivery_method = :smtp
    d.server_host = 'smtp.dev.activenetwork.com'
    d.server_port = 25
  end

  God.contact(:email) do |c|
    c.name = 'Smart Huang'
    c.group = 'TestPlus Team'
    c.to_email = 'smart.huang@activenetwork.com'
  end

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 30.seconds
      c.running = false
      c.notify = {:contacts => ['TestPlus Team'], :priority => 'Urgent', :category => 'production'}
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
