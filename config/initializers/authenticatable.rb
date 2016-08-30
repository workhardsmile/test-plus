rails_env = ENV['RAILS_ENV'] || 'development'
if rails_env == "production"
  $authenticate_method = :ldap_authenticatable
else
  $authenticate_method = :database_authenticatable
end
