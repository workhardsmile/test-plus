desc "init browsers and operation systems, also process existing ci mappings"
task :init_browser_and_os => :environment do
  win = OperationSystem.find{|os| os.name == 'windows' and os.version == 'xp'}
  win ||= OperationSystem.create!(:name => 'windows', :version => 'xp')
  ie = Browser.find{|b| b.name == 'ie' and b.version == '6.0'}
  ie ||= Browser.create!(:name => 'ie', :version => '6.0')
  firefox = Browser.find{|b| b.name == 'firefox' and b.version == '3.5'}
  firefox ||= Browser.create!(:name => 'firefox', :version => '3.5')
  chrome = Browser.find{|b| b.name == 'chrome' and b.version == '17'}
  chrome ||= Browser.create!(:name => 'chrome', :version => '17')

  Project.all.each do |p|
    p.browsers << ie
    p.browsers << firefox
    p.browsers << chrome
    p.operation_systems << win
    p.save!
  end

  CiMapping.all.each do |mapping|
    if mapping.browser.nil?
      mapping.browser = ie
      mapping.operation_system = win
      mapping.save!
    end
  end
end
