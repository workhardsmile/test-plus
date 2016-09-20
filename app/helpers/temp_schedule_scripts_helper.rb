module TempScheduleScriptsHelper
  def TempScheduleScriptsHelper.get_schedule_scripts(slave_name,platforms=[{}],project_names=[],threads_number=1,operation_system={},remote_ip='127.0.0.1')
    schedule_scripts = []
    platforms.each do |platform|
      project_names.each do |project_name|
        ActiveRecord::Base.connection.execute("call get_schedule_scripts_by_tnumber_and_project_and_platform(#{threads_number},'#{project_name}','#{platform['type']}','#{platform['version']}','#{operation_system['type']}','#{operation_system['version']}','#{slave_name}','#{remote_ip}')")
        wait_sql = "select count(*) num from information_schema.PROCESSLIST where STATE='executing' and INFO like '%get_schedule_scripts_by_tnumber_and_project_and_platform%'"
        10.times.each do |i|
          count = ActiveRecord::Base.connection.select(wait_sql)[0]["num"]
          break if count <= 1
          sleep(3)
        end
        temp_schedule_scripts = TempScheduleScript.find_all_by_project_name_and_platform_and_ip_and_deleted(project_name,platform['type'],remote_ip,0)||[]
        temp_schedule_scripts.each do |temp_schedule_script|
          schedule_scripts = schedule_scripts<<temp_schedule_script
          temp_schedule_script.deleted = 1
          temp_schedule_script.save!          
        end
      end
    end
    #ActiveRecord::Base.connection.execute("delete from temp_schedule_scripts where deleted=1")
    schedule_scripts
  end
end
