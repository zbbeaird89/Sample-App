require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
  
  test "redirects to root url when non-activated user tries to visit show page" do 
    @user.update_attribute(:activated, false)
    log_in_as(@user)
    get user_path(@user)
    assert_redirected_to root_url
  end

  test "renders show page when user is activated" do 
    log_in_as(@user)
    get user_path(@user)
    assert_template "users/show"
  end
end
