class AuthenticationController < ApplicationController
  def login
    user =User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)

      logger.debug "[LOG]: #{user} logined Succesfully.Token: #{token}"
      render json: {
        token: token,
        user: user
      },status: :ok
    else
      logger.warn "[LOG]: #{user} UNSUCCESFULLY."
      render json:{
        error: "Unsuccefull login"
      }, status: :unauthorized
    end
  end
end
