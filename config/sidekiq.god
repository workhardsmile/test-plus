# run with: god -c /path/to/xxxx.god -D
#
# This is the actual config file used to keep testplus web server running.

RAILS_ROOT = "/opt/test-plus"
SIDEKIQ_ROOT = "/opt/update-testlink"

God.watch do |w|
    w.name = "sidekiq-watcher"
    w.log = "#{RAILS_ROOT}/log/god-SIDEKIQ.log"
    w.interval = 30.seconds # default
    w.start = "cd #{SIDEKIQ_ROOT}&&bundle exec sidekiq"
    w.stop = "ps -ef|grep sidekiq|grep -v 'grep'|awk '{print $2}'|xargs kill -9"
    w.start_grace = 30.seconds
    w.restart_grace = 30.seconds
    w.pid_file = "#{SIDEKIQ_ROOT}/logs/sidekiq.pid"
    
    w.uid = 'iron'
    w.gid = 'iron'

    w.behavior(:clean_pid_file)

    God::Contacts::Email.defaults do |d|      
      d.from_name = 'TestPlus sidekiq monitoring'
      d.from_email = 'demo_db@163.com'
      d.delivery_method = :smtp
      d.server_host = 'smtp.163.com'
      d.server_port = 25
      d.server_auth = true
      d.server_domain='163.com'
      d.server_user = 'demo_db@163.com'
      d.server_password = '$******$'
    end

    God.contact(:email) do |c|
      c.name = 'Frank Wu'
      c.group = 'TestPlus Team'
      c.to_email = 'gang.wu@istuary.com'
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
        c.interval = 30.seconds
      end
      
      on.condition(:process_exits) do |c|
        c.notify = 'me'
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
