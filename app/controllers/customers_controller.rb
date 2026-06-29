class CustomersController < ApplicationController
  before_action :authorize_request
  before_action :set_customer, only: %i[show update destroy]

  def create
    logger.info("[LOG]: Customers#create starting user_id=#{current_user&.id} request_id=#{request.request_id}")
    customer = @current_user.customers.new(customer_params)

    if customer.save
      logger.info("[LOG]: Customers#create success customer_id=#{customer.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
      render json: customer, status: :created
    else
      logger.warn("[LOG]: Customers#create failed errors=#{customer.errors.full_messages.join(', ')} user_id=#{current_user&.id} request_id=#{request.request_id}")
      render json: {
        errors: customer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def index
    logger.info("[LOG]: Customers#index user_id=#{current_user&.id} request_id=#{request.request_id}")
    render json: @current_user.customers
  end

  def show
    logger.info("[LOG]: Customers#show customer_id=#{@customer.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
    render json: @customer
  end

  def update
    logger.info("[LOG]: Customers#update starting customer_id=#{@customer.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
    if @customer.update(customer_params)
      logger.info("[LOG]: Customers#update success customer_id=#{@customer.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
      render json: @customer
    else
      logger.warn("[LOG]: Customers#update failed customer_id=#{@customer.id} errors=#{@customer.errors.full_messages.join(', ')} request_id=#{request.request_id}")
      render json: {
        errors: @customer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    logger.info("[LOG]: Customers#destroy customer_id=#{@customer.id} user_id=#{current_user&.id} request_id=#{request.request_id}")
    @customer.destroy

    head :no_content
  end

  def summary
    logger.info("[LOG]: Customers#summary starting customer_id=#{params[:id]} user_id=#{current_user&.id} request_id=#{request.request_id}")
    customer = @current_user.customers.find(params[:id])

    orders = customer.orders

    render json: {
      customer_id: customer.id,
      summary: {
        total_orders: orders.count,
        completed_orders: orders.where(status: "Completed").count,
        pending_orders: orders.where(status: "Pending").count,
        total_amount: orders.sum(:total_amount),
        last_order_date: orders.maximum(:order_date)
      },
      recent_orders: orders.order(created_at: :desc).limit(5)
    }
  end

  private

  def set_customer
    @customer = @current_user.customers.find(params[:id])
  end

  def customer_params
    params.permit(
      :name,
      :email,
      :phone,
      :address
    )
  end
end
