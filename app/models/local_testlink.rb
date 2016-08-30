class LocalTestlink < ActiveRecord::Base
  establish_connection Rails.configuration.database_configuration['local_testlink']
end