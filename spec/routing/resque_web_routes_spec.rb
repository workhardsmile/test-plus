require "spec_helper"

describe "Resque Web Route" do
  # include Devise::TestHelpers

  it "should not route to resque web if user not logged in" do
    {:get => "/admin/resque"}.should_not be_routable
  end

  # it "should route to resque web if user logged in as admin" do
  #   user = Factory.create(:user)
  #   user.roles << Role.find_by_name(:admin)
  #   user.save!
  #   sign_in user
  #   # Comment this out because we're using request.env['warden'] to get user in CanAccessResque implementation and haven't figured out a way to mock that yet.
  #   # {:get => "/admin/resque"}.should be_routable
  # end

end
