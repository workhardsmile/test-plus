def create_adc_for_project(project, test_type, automation_driver, source_paths, source_main_path, source_control, sc_username=nil, sc_password = nil)
  adc = AutomationDriverConfig.find_or_create_by_name("#{project.name}_#{test_type}")
  adc.project_id = project.id
  adc.automation_driver_id = automation_driver.id
  adc.source_control = source_control
  adc.source_paths = source_paths.to_json
  adc.script_main_path = source_main_path
  adc.sc_username = sc_username
  adc.sc_password = sc_password
  adc.save
end


desc "add initial automation driver configs"
task :add_initial_adc => :environment do
  qtp_driver = AutomationDriver.find_or_create_by_name_and_version(:name => 'qtp', :version => '10.0')
  soapui_driver = AutomationDriver.find_or_create_by_name_and_version(:name => 'soapui', :version => '10.0')
  rspec_driver = AutomationDriver.find_or_create_by_name_and_version(:name => 'rspec', :version => '10.0')
  testng_driver = AutomationDriver.find_or_create_by_name_and_version(:name => 'testng', :version => '10.0')

  sc_username = "campsauto"
  sc_password = "!qaz2wsx1"
  hf_svn_username = "subrina"
  hf_svn_password = "active"
  p = Project.find_by_name('Camps')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\testsuites_testplus\\BVTs", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/testsuites_testplus/BVTs"}
    ]
    bvt_main_path = "C:\\QA Automation\\Camps\\trunk\\framework\\testsuites_testplus\\BVTs\\"

    create_adc_for_project(p, 'BVT', qtp_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)

    reg_source_paths = [
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Camps\\trunk\\framework\\testsuites_testplus\\regressions", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Camps/trunk/framework/regressions"}
    ]
    reg_main_path = "C:\\QA Automation\\Camps\\trunk\\framework\\testsuites_testplus\\regressions\\"

    create_adc_for_project(p, 'Regression', qtp_driver, reg_source_paths, reg_main_path, 'svn', sc_username, sc_password)
  end

  p = Project.find_by_name('Endurance')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\Dashboard BVTs", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/testsuites/Dashboard BVTs"}
    ]
    bvt_main_path = "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\Dashboard BVTs\\"

    create_adc_for_project(p, 'BVT', qtp_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)

    reg_source_paths = [
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\regressions", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/testsuites/regressions"}
    ]
    reg_main_path = "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\regressions\\"

    create_adc_for_project(p, 'Regression', qtp_driver, reg_source_paths, reg_main_path, 'svn', sc_username, sc_password)
  end

  p = Project.find_by_name('Sports')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\testsuites\\BVTs", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/testsuites/BVTs"}
    ]
    bvt_main_path = "C:\\QA Automation\\Sports\\trunk\\framework\\testsuites\\BVTs\\"

    create_adc_for_project(p, 'BVT', qtp_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)

    reg_source_paths = [
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Sports\\trunk\\framework\\testsuites\\regressions", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Sports/trunk/framework/testsuites/regressions"}
    ]
    reg_main_path = "C:\\QA Automation\\Sports\\trunk\\framework\\testsuites\\regressions\\"

    create_adc_for_project(p, 'Regression', qtp_driver, reg_source_paths, reg_main_path, 'svn', sc_username, sc_password)
  end

  p = Project.find_by_name('Giving')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\Dashboard BVTs", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/testsuites/Dashboard BVTs"}
    ]
    bvt_main_path = "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\Dashboard BVTs\\"

    create_adc_for_project(p, 'BVT', qtp_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)

    reg_source_paths = [
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\regressions\\FUI", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Endurance/trunk/framework/testsuites/regressions/FUI"}
    ]
    reg_main_path = "C:\\QA Automation\\Endurance\\trunk\\framework\\testsuites\\regressions\\FUI\\"

    create_adc_for_project(p, 'Regression', qtp_driver, reg_source_paths, reg_main_path, 'svn', sc_username, sc_password)
  end

  p = Project.find_by_name('Backoffice')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\testsuites\\Dashboard BVTs", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/testsuites/Dashboard BVTs"}
    ]
    bvt_main_path = "C:\\QA Automation\\Backoffice\\trunk\\framework\\testsuites\\Dashboard BVTs\\"

    create_adc_for_project(p, 'BVT', qtp_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)

    reg_source_paths = [
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\datapools", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/datapools"},
      {"local" => "C:\\QA Automation\\Backoffice\\trunk\\framework\\testsuites\\regressions", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Backoffice/trunk/framework/testsuites/regressions"}
    ]
    reg_main_path = "C:\\QA Automation\\Backoffice\\trunk\\framework\\testsuites\\regressions\\"

    create_adc_for_project(p, 'Regression', qtp_driver, reg_source_paths, reg_main_path, 'svn', sc_username, sc_password)
  end

  p = Project.find_by_name('Membership')
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\Membership\\trunk\\framework\\package", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Membership/trunk/framework/package"},
      {"local" => "C:\\QA Automation\\Membership\\trunk\\framework\\common", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Membership/trunk/framework/common"},
      {"local" => "C:\\QA Automation\\Membership\\trunk\\framework\\components", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Membership/trunk/framework/components"},
      {"local" => "C:\\QA Automation\\Membership\\trunk\\framework\\objects", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Membership/trunk/framework/objects"},
      {"local" => "C:\\QA Automation\\Membership\\trunk\\framework\\testsuites", "remote" => "https://fndsvn.dev.activenetwork.com/foundation/QA Automation/Membership/trunk/framework/testsuites"}
    ]
    bvt_main_path = "C:\\QA Automation\\Membership\\trunk\\framework\\"

    create_adc_for_project(p, '', rspec_driver, bvt_source_paths, bvt_main_path, 'svn', sc_username, sc_password)
  end

  #adc for HF project 
  p = Project.find_by_name("Florida")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "E:\\HF\\workspace\\HFReferenceProject\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/HFReferenceProject/target/classes"},
      {"local" => "E:\\HF\\workspace\\Florida\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Florida/target/classes"},
      {"local" => "E:\\HF\\workspace\\Florida\\target\\test-classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Florida/target/test-classes"}
    ]
    bvt_main_path = "E:\\HF\\workspace\\Florida\\target\\test-classes\\"
    create_adc_for_project(p, 'config', testng_driver, bvt_source_paths, bvt_main_path, 'svn', hf_svn_username, hf_svn_password)
  end

  p = Project.find_by_name("Pennsylvania")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "E:\\HF\\workspace\\HFReferenceProject\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/HFReferenceProject/target/classes"},
      {"local" => "E:\\HF\\workspace\\Pennsylvania\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Pennsylvania/target/classes"},
      {"local" => "E:\\HF\\workspace\\Pennsylvania\\target\\test-classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Pennsylvania/target/test-classes"}
    ]
    bvt_main_path = "E:\\HF\\workspace\\Pennsylvania\\target\\test-classes\\"
    create_adc_for_project(p, 'config', testng_driver, bvt_source_paths, bvt_main_path, 'svn', hf_svn_username, hf_svn_password)
  end

  p = Project.find_by_name("Louisiana")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "E:\\HF\\workspace\\HFReferenceProject\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/HFReferenceProject/target/classes"},
      {"local" => "E:\\HF\\workspace\\Louisiana\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Louisiana/target/classes"},
      {"local" => "E:\\HF\\workspace\\Louisiana\\target\\test-classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Louisiana/target/test-classes"}
    ]
    bvt_main_path = "E:\\HF\\workspace\\Louisiana\\target\\test-classes\\"
    create_adc_for_project(p, 'config', testng_driver, bvt_source_paths, bvt_main_path, 'svn', hf_svn_username, hf_svn_password)
  end

  p = Project.find_by_name("Kansas")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "E:\\HF\\workspace\\HFReferenceProject\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/HFReferenceProject/target/classes"},
      {"local" => "E:\\HF\\workspace\\Kansas\\target\\classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Kansas/target/classes"},
      {"local" => "E:\\HF\\workspace\\Kansas\\target\\test-classes", "remote" => "https://10.109.0.96/data/hfpa/ChengDuAutomation/Kansas/target/test-classes"}
    ]
    bvt_main_path = "E:\\HF\\workspace\\Kansas\\target\\test-classes\\"
    create_adc_for_project(p, 'config', testng_driver, bvt_source_paths, bvt_main_path, 'svn', hf_svn_username, hf_svn_password)
  end
  # adc for testplus project
  p = Project.find_by_name("TestPlus_Lynn")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\testplus-auto\\common", "remote" => "git://git.dev.activenetwork.com/aw-automation/testplus-auto.git"},
      {"local" => "C:\\QA Automation\\testplus-auto\\testsuites", "remote" => "git://git.dev.activenetwork.com/aw-automation/testplus-auto.git"}
    ]
    bvt_main_path = "C:\\QA Automation\\testplus-auto"

    create_adc_for_project(p, "", rspec_driver, bvt_source_paths, bvt_main_path, 'git', "", "")
  end

  p = Project.find_by_name("TestPlus_Emma")
  unless p.nil?
    bvt_source_paths = [
      {"local" => "C:\\QA Automation\\testplus-auto\\common", "remote" => "git://git.dev.activenetwork.com/aw-automation/testplus-auto.git"},
      {"local" => "C:\\QA Automation\\testplus-auto\\testsuites", "remote" => "git://git.dev.activenetwork.com/aw-automation/testplus-auto.git"}
    ]
    bvt_main_path = "C:\\QA Automation\\testplus-auto"

    create_adc_for_project(p, "", rspec_driver, bvt_source_paths, bvt_main_path, 'git', "", "")
  end
end
