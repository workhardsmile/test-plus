module TestRoundsHelper
  def get_eligible_slaves(project_name)
    slaves = []
    slaves << ["Run on All", 0]
    Slave.where(:active => true).all.each do |slave|
      if slave.project_name == '*' or slave.project_name_arr.index project_name
        slaves << [slave.name,slave.id]
      end
    end
    return slaves
  end

end
