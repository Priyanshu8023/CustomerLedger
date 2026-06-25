def login 
  user =User.find_by(email: params[:email])

  if user&.authenticate(params[:password])
    token=JWT.encode(user_id: user.id)

    logger.debug "[LOG]: User logged succesfully.Token: #{token}"
    render json:{
      token: token
    },status: :ok
  else 
    logger.warn "[LOG]: USER entered Invalid Credentails"
    render json:{
      error: "Invalid Credentails"
    },status: :unauthorized
  end
end
