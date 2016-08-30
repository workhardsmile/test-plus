module SlaveAssignmentsHelper

  def SlaveAssignmentsHelper.send_slave_assignment_to_list(slave_assignment, list_name)

    slave_assignments = $redis.hgetall :slave_assignments

    # if slave assignments is not nil and expected list has been created, update it
    slave_assignments.each do |name, value|
      sa_list = JSON.parse value
      # remove it if it exist
      sa_list.reject! {|sa| sa.nil? || sa["id"] == slave_assignment.id}
      # add to list if the list is what we expected to add in
      sa_list << JSON.parse(slave_assignment.to_json) if name == list_name.to_s
      $redis.hset :slave_assignments, name, JSON.generate(sa_list)
    end

    # if slave assignments is nil or expected list has't been created, create it
    if slave_assignments.nil? || !slave_assignments.has_key?(list_name.to_s)
      $redis.hset :slave_assignments, list_name, JSON.generate([slave_assignment.as_json])
    end

  end

end
