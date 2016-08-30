class ImportDataController < ApplicationController

  def import_test_suite
    project = Project.find_by_name(params[:project_name])
    creator_id = User.find_by_email(params[:creator_email]).id
    test_type_id = TestType.find_by_name(params[:test_type]).id
    as_names = params[:automation_scripts]
    if project and creator_id and test_type_id
      @ts = project.test_suites.find_or_create_by_name(params[:name])
      as_ids = project.automation_scripts.find_all_by_name(as_names).map(&:id)
      @ts.automation_script_ids = as_ids
      @ts.test_type_id = test_type_id
      @ts.creator_id = creator_id
      @ts.save
      render json: {"test suite name"=>@ts.name ,"automation_scripts" => @ts.automation_scripts.map(&:name)}
    else
      render json: {"Error" => "project name, creator email and test type are not correct"}
    end

  end


  def import_automation_script
    script = params[:data]["automation_script"]
    cases = params[:data]["automation_cases"]
    p = Project.find_by_name(script["project"])
    owner_id = User.find_or_create_default_by_email(script["owner"].downcase).id
    tp = p.test_plans.find_by_name(script["plan_name"])
    if (tp !=nil) and is_script_status_valid?(script["status"])
      as = p.automation_scripts.find_or_create_by_name(script["script_name"])
      as.automation_cases.delete_all
      as.test_plan_id = tp.id
      as.status = script["status"]
      as.note = script['comment']
      as.version = "1.0"
      as.project_id = p.id
      as.owner_id = owner_id
      as.tag_list = script["tags"] if script.has_key? 'tags'
      adc =  AutomationDriverConfig.find_by_name(script["auto_driver"])
      as.automation_driver_config_id = adc.id if adc
      as.time_out_limit = script["timeout"]
      case_array = ([]<<cases["case_id"]).flatten
      case_array.each do |c|
        tc = tp.test_cases.find_by_case_id(c)
        if tc != nil
          ac = as.automation_cases.find_or_create_by_case_id(tc.case_id)
          ac.name = tc.name
          ac.priority = tc.priority
          ac.version = "1.0"
          ac.save
        end
      end
      as.save
    end
    unless p.nil?
      delete_null_case_scripts(p.id)
    end
    render :nothing => true
  end
  def import_as_and_tc_status
    script = params[:data]["automation_script"]
    cases = params[:data]["automation_cases"]
    p = Project.find_by_name(script["project"])
    owner_id = User.find_or_create_default_by_email(script["owner"].downcase).id
    tp = p.test_plans.find_by_name(script["plan_name"])
    if (tp !=nil) and is_script_status_valid?(script["status"])
      as = p.automation_scripts.find_or_create_by_name(script["script_name"])
      as.automation_cases.delete_all
      as.test_plan_id = tp.id
      as.status = script["status"]
      as.note = script['comment']
      as.version = "1.0"
      as.project_id = p.id
      as.owner_id = owner_id
      as.tag_list = script["tags"] if script.has_key? 'tags'
      adc =  AutomationDriverConfig.find_by_name(script["auto_driver"])
      as.automation_driver_config_id = adc.id if adc
      as.time_out_limit = script["timeout"]
      case_array = ([]<<cases["case_id"]).flatten
      case_array.each do |c|
        tc = tp.test_cases.find_by_case_id(c)
        if tc != nil
          tc.automated_status = "Automated"
          tc.save
          ac = as.automation_cases.find_or_create_by_case_id(tc.case_id)
          ac.name = tc.name
          ac.priority = tc.priority
          ac.version = "1.0"
          ac.save
        end
      end
      as.save
    end
    render :nothing => true
  end
  def import_script_without_test_plan
    script = params[:data]["automation_script"]
    cases = params[:data]["automation_cases"]
    p = Project.find_by_name(script["project"])
    if (p != nil) and is_script_status_valid?(script["status"])
      tp = p.test_plans.find_or_create_by_name(script["name"])
      tp.status = script["status"]
      tp.version = "1.0"
      tp.save
      as = tp.automation_scripts.find_or_create_by_name(script["name"])
      as.automation_cases.delete_all
      as.status = script["status"]
      as.note = script['comment']
      as.version = "1.0"
      as.project_id = p.id
      as.tag_list = script["tags"] if script.has_key? 'tags'
      as.owner_id = User.find_or_create_default_by_email(script["owner"]).id
      adc =  AutomationDriverConfig.find_by_name(script["auto_driver"])
      as.automation_driver_config_id = adc.id if adc
      as.time_out_limit = script["timeout"]
      as.save
      info_array = ([]<<cases["case_info"]).flatten
      info_array.each do |c|
        tc = tp.test_cases.find_or_create_by_case_id(c.split('##').first)
        tc.name = c.split('##').last
        tc.version = "1.0"
        tc.priority = "P1"
        tc.automated_status = "Automated"
        tc.save
        ac = as.automation_cases.find_or_create_by_case_id(tc.case_id)
        ac.name = tc.name
        ac.priority = tc.priority
        ac.version = "1.0"
        ac.save
      end
      delete_null_case_scripts(p.id)
    end
    render :nothing => true
  end

  def import_test_plan_from_xml
    p = Project.find_by_name(params[:data]['project_name'])
    if p != nil
      test_plan =params[:data]['test_plan']
      tp = p.test_plans.find_or_create_by_name(test_plan['name'])
      tp.status = test_plan['status']
      tp.version = test_plan['version']
      tp.plan_type = test_plan['type']
      tp.project_id = p.id
      tp.save
      case_array =  ([]<<params[:data]["test_case"]).flatten
      case_array.each do |case_info|
        tc = tp.test_cases.find_or_create_by_case_id(case_info['case_id'])
        tc.name = case_info['name']
        tc.priority = case_info['priority']
        tc.automated_status = case_info['automated_status']
        tc.version = case_info['version']
        tc.test_plan_id = tp.id
        tc.save
        step_array = (([]<<case_info["test_step"]).flatten)
        step_array.each do |step_info|
          ts = tc.tc_steps.find_or_create_by_step_number(step_info['order_number'])
          ts.step_action = step_info['step']
          ts.expected_result = step_info['expected_result']
          ts.test_case_id = tc.id
          ts.save
        end
      end
    end
  end

  def refresh_testlink_data

    ImportTestlinkConfig.where(:active => true).each do |mapping|
      testplus_project_name = mapping.testplus_project
      project_name = mapping.testlink_project
      mp = Project.find_by_name(testplus_project_name)
      unless mp.nil?
        get_project_by_name = "select id,name from old_projects where name ='#{project_name}'"
        local_projects = LocalTestlink.connection.execute(get_project_by_name)
        local_projects.each do |p|
          mp.test_plans.update_all(:status => "expired")
          mp.test_plans.all.each do |mtp|
            mtp.test_cases.update_all(:version => "expired")
            mtp.save
          end
          get_tp_query = "select * from old_test_plans where project_id = '#{p[0]}' limit 9999999"
          local_test_plans = LocalTestlink.connection.execute(get_tp_query)
          local_test_plans.each do |tp|
            mtp = mp.test_plans.find_or_create_by_name(tp[2].strip.gsub(/\s+/,' '))
            mtp.status = "completed"
            mtp.version = tp[3]
            mtp.plan_type = tp[5]
            mtp.save
            get_tc_query = "select * from old_test_cases where test_plan_id = '#{tp[0]}' limit 9999999"
            local_test_cases = LocalTestlink.connection.execute(get_tc_query)
            local_test_cases.each do |tc|
              mtc = mtp.test_cases.find_or_create_by_case_id(tc[3])
              mtc.tc_steps.delete_all
              mtc.name = tc[2].strip
              mtc.version = tc[4]
              mtc.priority = "P#{4-tc[5]}"
              mtc.automated_status = tc[6]
              mtc.test_link_id = tc[7]
              mtc.keywords = tc[8]
              mtc.save
            end
          end
          get_test_steps = ("select ts.step_number as step_number,
                            ts.action as step_action,
                            ts.expected_result as expected_result,
                            tc.case_id as test_case_id,
                            ts.test_link_id as test_link_id
                            from old_test_steps ts
                            join old_test_cases tc on tc.id = ts.test_case_id
                            where tc.test_plan_id in (
                            select id from old_test_plans
                            where project_id =(select id from old_projects where name ='#{project_name}'))
                            limit 99999
                            ")
          old_test_steps = LocalTestlink.connection.execute(get_test_steps)
          step_records = []
          old_test_steps.each do |ts|
            if TestCase.where(:case_id =>ts[3]).first != nil
              ts[3] = TestCase.where(:case_id =>ts[3]).first['id']
              record = ts.collect{ |d| "'" + d.to_s.gsub("\\","").gsub("'","").gsub("\"","") + "'" }.join(",")
              begin
                ActiveRecord::Base.connection.insert "INSERT INTO tc_steps (step_number,step_action,expected_result,test_case_id,test_link_id) VALUES (#{record})"
              rescue Exception => e
                logger.info "Error in updating test steps, => #{e}"
              end
            end
          end
        end
      end
    end
    TestPlan.where(:status => 'expired').delete_all
    render :nothing => true
  end
  protected
  def delete_null_case_scripts(project_id)
    @project ||= Project.find(project_id)
    @project.automation_scripts.each do |automation_script|
      if automation_script.automation_cases.length == 0
        automation_script.destroy
      end
    end
  end

  private
  def is_script_status_valid?(status)
    ['Completed', 'Work In Progress', 'Disabled', 'Known Bug', 'Test Data Issue'].include? status
  end

end
