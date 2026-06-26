class ApplicationController < ActionController::API
  attr_reader :current_user
  around_action :log_request

  private

  def log_request
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    logger.info(
      "[LOG]: Start method=#{request.request_method} path=#{request.fullpath} " \
      "controller=#{controller_name} action=#{action_name} request_id=#{request.request_id}"
    )

    yield
  rescue StandardError => e
    logger.error(
      "[LOG]: Error method=#{request.request_method} path=#{request.fullpath} " \
      "controller=#{controller_name} action=#{action_name} " \
      "request_id=#{request.request_id} error=#{e.class} message=#{e.message}"
    )
    raise
  ensure
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(1)
    logger.info(
      "[LOG]: Finish method=#{request.request_method} path=#{request.fullpath} " \
      "controller=#{controller_name} action=#{action_name} status=#{response.status} " \
      "duration_ms=#{duration_ms} user_id=#{current_user&.id} request_id=#{request.request_id}"
    )
  end

  def authorize_request
    token = extracted_token

    if token.blank?
      logger.warn(
        "[LOG]: Missing token controller=#{controller_name} action=#{action_name} " \
        "path=#{request.fullpath} request_id=#{request.request_id}"
      )
      render json: { error: "Missing token" }, status: :unauthorized
      return
    end

    decoded = JsonWebToken.decode(token)

    if decoded.nil?
      logger.warn(
        "[LOG]: Invalid token controller=#{controller_name} action=#{action_name} " \
        "path=#{request.fullpath} request_id=#{request.request_id}"
      )
      render json: { error: "Invalid token" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded[:user_id])

    if @current_user.nil?
      logger.warn(
        "[LOG]: User not found controller=#{controller_name} action=#{action_name} " \
        "user_id=#{decoded[:user_id]} path=#{request.fullpath} request_id=#{request.request_id}"
      )
      render json: { error: "User not found" }, status: :unauthorized
      return
    end

    logger.info(
      "[LOG]: Authenticated controller=#{controller_name} action=#{action_name} " \
      "user_id=#{@current_user.id} request_id=#{request.request_id}"
    )
  end

  def extracted_token
    bearer_token ||
      request.headers["X-Access-Token"].presence ||
      request.headers["x-access-token"].presence ||
      params[:token].presence
  end

  def bearer_token
    header = request.authorization || request.headers["Authorization"]
    return if header.blank?

    match = header.match(/\ABearer\s+(.+)\z/i)
    return match&.captures&.first if match

    header.strip
  end
end
