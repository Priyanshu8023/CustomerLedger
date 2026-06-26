class OrdersController < ApplicationController
  before_action :authorize_request

  def create
    logger.info("[LOG]: Orders#create starting user_id=#{current_user&.id} customer_id=#{params[:customer_id]} request_id=#{request.request_id}")
    customer = @current_user.customers.find(params[:customer_id])

    order = @current_user.orders.new(
      order_params.merge(customer: customer)
    )

    if order.save
      logger.info("[LOG]: Orders#create success order_id=#{order.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
      render json: order, status: :created
    else
      logger.warn("[LOG]: Orders#create failed errors=#{order.errors.full_messages.join(', ')} user_id=#{current_user&.id} request_id=#{request.request_id}")
      render json: {
        errors: order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def summary
    logger.info("[LOG]: Orders#summary user_id=#{current_user&.id} request_id=#{request.request_id}")
    orders = @current_user.orders

    render json: {
      total_orders: orders.count,
      completed_orders: orders.where(status: "Completed").count,
      pending_order: orders.where(status: "Pending").count,
      total_revenue: orders.sum(:total_amount),
      today_orders: orders.where(order_date: Date.current).count
    }
  end

  private

  def order_params
    params.permit(
      :customer_id,
      :total_amount,
      :status,
      :order_date,
      :notes
    )
  end
end
