# run with: god -c /path/to/xxxx.god -D
#
# This is the actual config file used to keep testplus resque job running.

RAILS_ENV   = ENV['RAILS_ENV']  || "production"
RAILS_ROOT  = ENV['RAILS_ROOT'] || "/home/active/testplus/testplus-web-main"

["testplus_farm","testplus_mailer","testplus_data_sync"].each do |name|
  God.watch do |w|
    w.dir      = "#{RAILS_ROOT}"
    w.name     = "resque-#{name}-watcher"
    w.group    = 'resque'
    w.interval = 60.seconds
    w.env      = {"QUEUE"=>name, 'PIDFILE' => "#{RAILS_ROOT}/tmp/pids/#{name}.pid"}
    w.start    = "cd #{RAILS_ROOT}/ && RAILS_ENV=#{RAILS_ENV} rake environment resque:work QUEUE=#{name}"
    w.start_grace   = 60.seconds
    w.log      = "#{RAILS_ROOT}/log/god-resque-#{name}.log"

    w.uid = 'active'
    w.gid = 'active'

    God::Contacts::Email.defaults do |d|
      d.from_email = 'testplus@active.com'
      d.from_name = 'TestPlus resque monitoring'
      d.delivery_method = :smtp
      d.server_host = 'mx1.dev.activenetwork.com'
      d.server_port = 25
    end

    God.contact(:email) do |c|
      c.name = 'Eric Yang'
      c.group = 'TestPlus Team'
      c.to_email = 'eric.yang@activenetwork.com'
    end

    God.contact(:email) do |c|
      c.name = 'Tyrael Tong'
      c.group = 'TestPlus Team'
      c.to_email = 'tyrael.tong@activenetwork.com'
    end

    God.contact(:email) do |c|
      c.name = 'Smart Huang'
      c.group = 'TestPlus Team'
      c.to_email = 'smart.huang@activenetwork.com'
    end

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 60.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 60.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
        c.notify = {:contacts => ['TestPlus Team'], :priority => 'Urgent', :category => 'production'}
      end
    end
  end
end
