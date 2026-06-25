class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authorize_request
    token = bearer_token || request.headers["x-access-token"]

    if token.blank?
      render json: { error: "Missing token" }, status: :unauthorized
      return
    end

    decoded = JsonWebToken.decode(token)

    if decoded.nil?
      render json: { error: "Invalid token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded[:user_id])

    if @current_user.nil?
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  def bearer_token
    header = request.headers["Authorization"]
    return if header.blank?

    match = header.match(/\ABearer\s+(.+)\z/i)
    match&.captures&.first
  end
end
