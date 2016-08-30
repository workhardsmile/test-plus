# run with: god -c /path/to/xxxx.god -D
#
# This is the actual config file used to keep testplus web server running.

RAILS_ROOT = "/home/active/testplus/testplus-web-main"
NGINX_ROOT = "/opt/nginx"

%w{3000}.each do |port|
  God.watch do |w|
    w.name = "nginx-watcher"
    w.log = "#{RAILS_ROOT}/log/god-nginx.log"
    w.interval = 30.seconds # default
    w.start = "#{NGINX_ROOT}/sbin/nginx"
    w.stop = "#{NGINX_ROOT}/sbin/nginx -s stop"
    w.restart = "touch #{RAILS_ROOT}/tmp/restart.txt"
    w.start_grace = 30.seconds
    w.restart_grace = 30.seconds
    w.pid_file = "#{NGINX_ROOT}/logs/nginx.pid"

    w.behavior(:clean_pid_file)

    God::Contacts::Email.defaults do |d|
      d.from_email = 'testplus@active.com'
      d.from_name = 'TestPlus nginx monitoring'
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

    w.transition(:up, :start) do |on|
      on.condition(:process_exits) do |c|
        c.notify = 'me'
      end
    end

    #w.restart_if do |restart|
    #  restart.condition(:http_response_code) do |c|
    #   c.host = 'localhost'
    #   c.port = 3000
    #   c.path = '/'
    #   c.timeout = 30.seconds
    #   c.times = [4, 5]
    #   c.code_is_not = [200, 304]
    # end

     # restart.condition(:memory_usage) do |c|
     #   c.above = 150.megabytes
     #   c.times = [3, 5] # 3 out of 5 intervals
     # end

     # restart.condition(:cpu_usage) do |c|
     #   c.above = 50.percent
     #   c.times = 5
     # end
    #end

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
end
