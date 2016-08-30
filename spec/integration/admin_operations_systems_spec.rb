require 'spec_helper'

describe "operation system admin page" do
  before do
    @user = User.create!(:email => 'test@testplus.com',
                         :password => 'testtest',
                         :password_confirmation => 'testtest',
                         :display_name => "TestPlus Test"
                         )
    ab = AbilityDefinition.create!(:ability => :manage,
                              :resource => 'OperationSystem',
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

    click_button('Sign in')
    page.should have_content('Login as TestPlus Test')
  end

  it "should display operation system section on Admin page" do
    visit '/admin/projects'
    page.should have_link("Operation Systems", {:href => '/admin/operation_systems'})
  end

  it "should display no data indication when no operation systems" do
    visit '/admin/operation_systems'
    page.should have_content("Listing Operation Systems")
    page.should have_content("No data")
  end
  it "should display browser data if there's any" do
    OperationSystem.create!(:name => 'Windows',
                    :version => 'XP'
                    )
    visit '/admin/operation_systems'
    page.should_not have_content('No data')
    page.should have_content("Windows")
    page.should have_content("XP")
  end

  it "should be able to create browser" do
    visit '/admin/operation_systems'
    page.should have_link("New Operation System")
    page.click_link "New Operation System"
    page.should have_content("New Operation System")
    fill_in 'operation_system[version]', :with => "XP"
    fill_in 'operation_system[name]', :with => "Windows"
    click_button "Save"
    OperationSystem.count.should eql 1
    page.should have_content("Windows")
    page.should have_content("XP")
    Browser.all.each do |b|
      page.should have_link("", {:href => "/admin/operation_systems/#{b.id}/edit"})
      page.should have_link("", {:href => "/admin/operation_systems/#{b.id}", "data-method" => 'delete'})
    end
  end

  it "should not allow empty browser name or version" do
    visit '/admin/operation_systems'
    page.click_link "New Operation System"
    fill_in 'operation_system[version]', :with => 'XP'
    click_button 'Save'
    page.should have_content("Name can't be blank")
    fill_in 'operation_system[version]', :with => ''
    fill_in 'operation_system[name]', :with => 'Windows'
    click_button 'Save'
    page.should have_content("Version can't be blank")
  end

  it "should not allow create duplicate browser combinations" do
    OperationSystem.create!(:name => "Windows", :version => "XP")
    visit '/admin/operation_systems'
    page.click_link "New Operation System"
    fill_in 'operation_system[name]', :with => "Windows"
    fill_in 'operation_system[version]', :with => "XP"
    click_button 'Save'
    page.should have_content("Version has already been taken")
  end

  it "should be able to edit operaton system" do
    OperationSystem.create!(:name => "Windows", :version => "XP")
    visit "/admin/operation_systems/#{OperationSystem.last.id}/edit"
    fill_in 'operation_system[version]', :with => '7'
    click_button 'Save'
    OperationSystem.last.version.should eql '7'

  end
end
