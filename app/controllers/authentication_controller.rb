class AuthenticationController < ApplicationController
  def login
    logger.info("[LOG]: Authentication#login starting request_id=#{request.request_id}")
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)

      logger.info("[LOG]: Authentication#login success user_id=#{user.id} request_id=#{request.request_id}")
      render json: {
        user_id: user.id,
        user_name: user.name,
        token: token,
      }, status: :ok
    else
      logger.warn("[LOG]: Authentication#login failed email=#{params[:email]} request_id=#{request.request_id}")
      render json: {
        error: "Unsuccefull login"
      }, status: :unauthorized
    end
  end
end
