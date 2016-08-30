require 'spec_helper'

describe "schedule test round" do
  before do
    @user = User.create!(:email => 'test@testplus.com',
                         :password => 'testtest',
                         :password_confirmation => 'testtest',
                         :display_name => "TestPlus Test"
                         )
    ab = AbilityDefinition.create!(:ability => :manage,
                              :resource => 'Project'
                              )
    ab2 = AbilityDefinition.create!(:ability => :manage,
                                   :resource => 'TestRound'
                                   )

    AbilityDefinitionsUsers.create!(:user_id => @user.id,
                                    :ability_definition_id => ab.id
                                    )

    AbilityDefinitionsUsers.create!(:user_id => @user.id,
                                    :ability_definition_id => ab2.id
                                    )

    Capybara.reset_sessions!
    visit '/users/sign_in'
    page.should have_content('Sign in')
    page.should have_button('Sign in')
    fill_in 'user[email]', :with => 'test@testplus.com'
    fill_in 'user[password]', :with => 'testtest'
    click_button('Sign in')

    @project = Project.new(name: 'test', leader: @user)

    @ie = Browser.create!(:name => 'IE', :version => '6.0')
    @firefox = Browser.create!(:name => 'Firefox', :version => '3.5')

    @win = OperationSystem.create!(:name => 'Windows', :version => 'XP')
    @win7 = OperationSystem.create!(:name => 'Windows', :version => '7')

    @project.browsers << @ie
    @project.browsers << @firefox
    @project.operation_systems << @win
    @project.operation_systems << @win7
    @project.save!
    TestType.create(:name => 'BVT')
    TestEnvironment.create(:name => 'INT Latest', :value => 'INT')
    AutomationScript.create(:name => "Test Automation Script")

    @test_suite = @project.test_suites.build(:name => 'test suite1')
    @test_suite.automation_scripts << AutomationScript.last
    @test_suite.test_type = TestType.last
    @test_suite.save!
  end

  it "should display a list of browser and operation system" do
    visit "/projects/#{@project.id}/test_rounds"
    page.should have_link 'Schedule'
    click_link 'Schedule'
    fill_in 'test_round[test_object]', :with => 'test object 001'
    page.should have_select 'test_round[test_suite_id]'
    select 'test suite1', :from => 'test_round[test_suite_id]'
    page.should have_select 'test_round[test_environment_id]'
    select 'INT Latest', :from => 'test_round[test_environment_id]'
    page.should have_select 'test_round[browser_id]', :options => ['IE, 6.0', 'Firefox, 3.5']
    page.should have_select 'test_round[operation_system_id]', :options => ['Windows, XP', 'Windows, 7']
    click_button 'Schedule!'
    TestRound.count.should eql 1
    tr = TestRound.last
    tr.browser.name.should eql 'IE'
    tr.browser.version.should eql '6.0'
    tr.operation_system.name.should eql 'Windows'
    tr.operation_system.version.should eql 'XP'
  end
end
