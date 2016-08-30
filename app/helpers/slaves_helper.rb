module SlavesHelper

  def self.send_slave_to_update_list(slave_id)
    $redis.sadd :slaves_to_be_updated, slave_id if slave_id
  end

end
