class CustomersController < ApplicationController

  def create
    customer = @current_user.customers.new(customer_params)

    if customer.save
      logger.debug "[LOG]: Customer created properly"
      render json: customer, status: :created
    else
      logger.warn "[LOG]: Failed to create customer. Error: #{customer.errors.full_messages}"
      render json: {
        errors: customer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def index
    render json: @current_user.customers
  end

  def show
    customer = @current_user.customers.find(params[:id])

    render json: customer
  end

  def update
    customer = @current_user.customers.find(params[:id])

    if customer.update(customer_params)
      render json: customer
    else
      render json: {
        errors: customer.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    customer = @current_user.customers.find(params[:id])
    customer.destroy

    head :no_content
  end

  private

  def customer_params
    params.permit(
      :name,
      :email,
      :phone,
      :address
    )
  end
end
