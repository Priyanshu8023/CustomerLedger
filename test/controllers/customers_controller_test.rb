require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Test User",
      email: "test-user-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  test "rejects requests without a token" do
    get "/customer"

    assert_response :unauthorized
    assert_equal "Missing token", response.parsed_body["error"]
  end

  test "accepts a raw authorization token" do
    get "/customer", headers: { "Authorization" => @token }

    assert_response :success
  end

  test "accepts a bearer authorization token" do
    get "/customer", headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :success
  end

  test "accepts an x-access-token header" do
    get "/customer", headers: { "X-Access-Token" => @token }

    assert_response :success
  end

  test "creates a customer for the authenticated user" do
    assert_difference -> { @user.customers.count }, 1 do
      post "/customer",
        params: {
          name: "Acme",
          email: "acme-#{SecureRandom.hex(4)}@example.com",
          phone: "1234567890",
          address: "Main Street"
        },
        headers: { "Authorization" => "Bearer #{@token}" }
    end

    assert_response :created
    assert_equal "Acme", response.parsed_body["name"]
  end

  test "deletes a customer for the authenticated user" do
    customer = @user.customers.create!(
      name: "To Delete",
      email: "delete-#{SecureRandom.hex(4)}@example.com"
    )

    assert_difference -> { @user.customers.count }, -1 do
      delete "/customer/#{customer.id}", headers: { "Authorization" => @token }
    end

    assert_response :no_content
  end

  test "returns a customer summary" do
    customer = @user.customers.create!(
      name: "Summary Customer",
      email: "summary-#{SecureRandom.hex(4)}@example.com"
    )

    @user.orders.create!(
      customer: customer,
      total_amount: 125.50,
      status: "Completed",
      order_date: Date.current,
      notes: "First order"
    )

    @user.orders.create!(
      customer: customer,
      total_amount: 75.00,
      status: "Pending",
      order_date: Date.current - 1.day,
      notes: "Second order"
    )

    get "/customers/#{customer.id}/summary", headers: { "Authorization" => @token }

    assert_response :success
    assert_equal 2, response.parsed_body.dig("summary", "total_orders")
    assert_equal 1, response.parsed_body.dig("summary", "completed_orders")
    assert_equal 1, response.parsed_body.dig("summary", "pending_orders")
  end
end
