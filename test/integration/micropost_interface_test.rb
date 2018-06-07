require 'test_helper'

class MicropostInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do 
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    assert_select "input[type=file]"
    #Invalid submission
    assert_no_difference "Micropost.count" do 
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    #Valid submission
    content = "This is my test micropost!"
    picture = fixture_file_upload("test/fixtures/rails.png", "image/png")
    assert_difference "Micropost.count", 1 do 
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    assert @user.microposts.first.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    #Delete post
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do 
      delete micropost_path(first_micropost)
    end
    #View other user's page (No delete links)
    get user_path(users(:archer))
    assert_select "a", text: "delete", count: 0
  end

  test "micropost sidebar count" do 
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    #user with 0 microposts
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "This is the first micropost!")
    get root_path
    assert_match "1 micropost", response.body
  end
end
