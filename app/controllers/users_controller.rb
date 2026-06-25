class UsersController < ApplicationController
  def create 
    user=User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      logger.debug "[LOG]: USER create Sucessfully. TOKEN: #{token}"
      render json: {
        message: "User Created",
        token: token,
      },status: :created
    else 
      logger.warn "[LOG]: USER not created.ERROR: #{user.errors.full_messages}"
      render json:{
        error: user.errors.full_messages
      },status: :unprocessable_entity
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
