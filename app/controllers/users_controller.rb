class UsersController < ApplicationController
  def create
    logger.info("[LOG]: users#create starting request_id=#{request.request_id}")
    user = User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      logger.info("[LOG]: users#create success user_id=#{user.id} request_id=#{request.request_id}")
      render json: {
        message: "User Created",
        token: token,
      }, status: :created
    else
      logger.warn("[LOG]: users#create failed errors=#{user.errors.full_messages.join(', ')} request_id=#{request.request_id}")
      render json: {
        error: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(
      user: [
        :name,
        :email,
        :password,
        :password_confirmation
      ]
    )
  end
end
