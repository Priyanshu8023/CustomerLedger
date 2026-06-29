require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Dashboard User",
      email: "dashboard-user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = JsonWebToken.encode(user_id: @user.id)
    @customer = @user.customers.create!(
      name: "Dashboard Customer",
      email: "dashboard-customer-#{SecureRandom.hex(4)}@example.com"
    )
  end

  test "returns dashboard metrics for the authenticated user" do
    completed_order = @user.orders.create!(
      customer: @customer,
      total_amount: 125.50,
      status: "Completed",
      order_date: Date.current,
      notes: "Completed order"
    )

    @user.orders.create!(
      customer: @customer,
      total_amount: 75.00,
      status: "Pending",
      order_date: Date.current - 1.day,
      notes: "Pending order"
    )

    other_user = User.create!(
      name: "Other User",
      email: "other-user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    other_customer = other_user.customers.create!(
      name: "Other Customer",
      email: "other-customer-#{SecureRandom.hex(4)}@example.com"
    )
    other_user.orders.create!(
      customer: other_customer,
      total_amount: 999.00,
      status: "Completed",
      order_date: Date.current
    )

    get "/dashboard", headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :success
    assert_equal 1, response.parsed_body["total_customers"]
    assert_equal 2, response.parsed_body["total_orders"]
    assert_equal 1, response.parsed_body["completed_orders"]
    assert_equal 1, response.parsed_body["pending_orders"]
    assert_equal 200.5, response.parsed_body["total_revenue"].to_f
    assert_equal 1, response.parsed_body["today_orders"]
    assert_equal 2, response.parsed_body["recent_orders"].length
    assert_includes response.parsed_body["recent_orders"].map { |order| order["id"] }, completed_order.id
  end

  test "rejects dashboard requests without a token" do
    get "/dashboard"

    assert_response :unauthorized
    assert_equal "Missing token", response.parsed_body["error"]
  end

  test "rejects dashboard requests with an invalid token" do
    get "/dashboard", headers: { "Authorization" => "Bearer invalid-token" }

    assert_response :unauthorized
    assert_equal "Invalid token", response.parsed_body["error"]
  end
end
