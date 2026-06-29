class DashboardController < ApplicationController
  before_action :authorize_request

  def show
    logger.info("[LOG]: Dashboard#show user_id=#{current_user.id} request_id=#{request.request_id}")

    orders = current_user.orders

    render json: {
      total_customers: current_user.customers.count,
      total_orders: orders.count,
      completed_orders: orders.where(status: "Completed").count,
      pending_orders: orders.where(status: "Pending").count,
      total_revenue: orders.sum(:total_amount),
      today_orders: orders.where(order_date: Date.current).count,
      recent_orders: recent_orders
    }, status: :ok
  end

  private

  def recent_orders
    current_user.orders.includes(:customer).order(created_at: :desc).limit(5).map do |order|
      {
        id: order.id,
        order_number: order.order_number,
        customer_id: order.customer_id,
        customer_name: order.customer.name,
        total_amount: order.total_amount,
        status: order.status,
        order_date: order.order_date
      }
    end
  end
end
