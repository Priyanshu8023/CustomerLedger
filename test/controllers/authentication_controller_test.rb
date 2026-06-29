require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Auth User",
      email: "auth-user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  test "logs out an authenticated user" do
    post "/logout", headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :success
    assert_equal "Logged out successfully", response.parsed_body["message"]
  end

  test "rejects logout without a token" do
    post "/logout"

    assert_response :unauthorized
    assert_equal "Missing token", response.parsed_body["error"]
  end

  test "rejects logout with an invalid token" do
    post "/logout", headers: { "Authorization" => "Bearer invalid-token" }

    assert_response :unauthorized
    assert_equal "Invalid token", response.parsed_body["error"]
  end
end
