require 'spec_helper'

describe "project admin page" do
  before do
    @user = User.create!(:email => 'test@testplus.com',
                         :password => 'testtest',
                         :password_confirmation => 'testtest',
                         :display_name => "TestPlus Test"
                         )
    ab = AbilityDefinition.create!(:ability => :manage,
                              :resource => 'Project',
                              )
    AbilityDefinitionsUsers.create!(:user_id => @user.id,
                                    :ability_definition_id => ab.id
                                    )
    Capybara.reset_sessions!
    visit '/users/sign_in'
    page.should have_content('Sign in')
    page.should have_button('Sign in')
    fill_in 'user[email]', :with => 'test@testplus.com'
    fill_in 'user[password]', :with => 'testtest'

    Browser.create!(:name => 'IE', :version => '6.0')
    Browser.create!(:name => 'Firefox', :version => '3.5')

    OperationSystem.create!(:name => 'Windows', :version => 'XP')
    OperationSystem.create!(:name => 'Windows', :version => '7')

    click_button('Sign in')
    page.should have_content('Login as TestPlus Test')
  end

  it "should include browser and operation system select options when create a new project" do
    visit '/admin/projects'
    page.click_link "New Project"
    page.should have_select('project[operation_systems][]')
    page.should have_select('project[browsers][]')
  end

  it "should be able to create project with browser and operation system selections" do
    visit '/admin/projects'
    page.click_link 'New Project'
    fill_in 'project[name]', :with => "Test"
    select 'Windows, XP', :from => 'project[operation_systems][]'
    select 'Firefox, 3.5', :from => 'project[browsers][]'
    click_button 'Save'
    Project.last.browsers.count.should eql 1
    Project.last.operation_systems.count.should eql 1
    Project.last.browsers.last.name.should eql 'Firefox'
    Project.last.browsers.last.version.should eql '3.5'
    Project.last.operation_systems.last.name.should eql 'Windows'
    Project.last.operation_systems.last.version.should eql 'XP'
  end

  it "should support select multiple browsers and operation systems" do
    visit '/admin/projects'
    page.click_link 'New Project'
    fill_in 'project[name]', :with => "Test"
    select 'Windows, XP', :from => 'project[operation_systems][]'
    select 'Firefox, 3.5', :from => 'project[browsers][]'
    select 'Windows, 7', :from => 'project[operation_systems][]'
    select 'IE, 6.0', :from => 'project[browsers][]'
    click_button 'Save'
    Project.last.browsers.count.should eql 2
    Project.last.operation_systems.count.should eql 2
  end

  it "shouldn't allow creating project without browser or operation system" do
    visit '/admin/projects'
    page.click_link 'New Project'
    fill_in 'project[name]', :with => "Test"
    click_button 'Save'
    page.should have_content("Browsers can't be blank")
    page.should have_content("Operation systems can't be blank")
  end

  it "should be able to edit browsers for a project" do
    visit '/admin/projects'
    page.click_link 'New Project'
    fill_in 'project[name]', :with => "Test"
    select 'Windows, XP', :from => 'project[operation_systems][]'
    select 'Firefox, 3.5', :from => 'project[browsers][]'
    select 'Windows, 7', :from => 'project[operation_systems][]'
    select 'IE, 6.0', :from => 'project[browsers][]'
    click_button 'Save'
    visit "/admin/projects/#{Project.last.id}/edit"
    unselect 'Firefox, 3.5', :from => 'project[browsers][]'
    unselect 'Windows, XP', :from => 'project[operation_systems][]'
    click_button 'Save'
    Project.last.browsers.count.should eql 1
    Project.last.operation_systems.count.should eql 1
  end

end
