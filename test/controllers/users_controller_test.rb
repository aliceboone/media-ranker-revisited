require "test_helper"

describe UsersController do

  describe 'Index' do
    it 'should get index' do
      get '/users'
      must_respond_with :success
    end
  end

  describe 'Show' do

    it 'can get a valid user' do
      user = users(:dan)

      get user_path(user.id)
      must_respond_with :success
    end

    it 'will redirect for an invalid user' do
      get user_path(-1)
      must_respond_with :not_found
    end
  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root path" do

      start_count = User.count
      user = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do

      start_count = User.count
      user = User.new(provider: 'github', uid: 554433, email: 'potus@whitehouse.gov', username: 'Alice')

      perform_login(user)

      must_redirect_to root_path

      # Should have created a new user
      expect(User.count).must_equal start_count + 1

      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid merchant data" do
      user = User.find_by(username: 'dan')
      user.username = nil

      perform_login(user)

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "logout" do
    it "can logout an existing user" do
      # Arrange
      user = perform_login(users(:dan))
      expect(session[:user_id]).must_equal user.id

      # Act
      expect {
        post logout_path
      }.wont_change "User.count"

      # Assert
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end
