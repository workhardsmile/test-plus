rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/redis.yml')
$redis = Redis.new(resque_config[rails_env])

Resque.redis = $redis
