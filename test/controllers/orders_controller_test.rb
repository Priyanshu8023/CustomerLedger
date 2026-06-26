require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Test User",
      email: "test-user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = JsonWebToken.encode(user_id: @user.id)
    @customer = @user.customers.create!(
      name: "Summary Customer",
      email: "summary-#{SecureRandom.hex(4)}@example.com"
    )
  end

  test "returns an orders summary" do
    @user.orders.create!(
      customer: @customer,
      total_amount: 125.50,
      status: "Completed",
      order_date: Date.current,
      notes: "First order"
    )

    @user.orders.create!(
      customer: @customer,
      total_amount: 75.00,
      status: "Pending",
      order_date: Date.current - 1.day,
      notes: "Second order"
    )

    get "/orders/summary", headers: { "Authorization" => @token }

    assert_response :success
    assert_equal 2, response.parsed_body["total_orders"]
    assert_equal 1, response.parsed_body["completed_orders"]
    assert_equal 1, response.parsed_body["pending_order"]
    assert_equal 200.5, response.parsed_body["total_revenue"].to_f
  end
end
