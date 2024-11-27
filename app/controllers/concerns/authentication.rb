module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  private

  def authenticate_user
    access_token = request.headers["Authorization"]&.split(" ")&.last
    if access_token
      user_id = get_user_id_from_token(access_token)
      if user_id
        @current_user = User.find_by(id: user_id)
      else
        render json: { errorMessage: "Invalid token" }, status: :unauthorized
      end
    else
      render json: { errorMessage: "Not authenticated" }, status: :unauthorized
    end
  end

  def get_user_id_from_token(access_token)
    redis = Redis.new(host: "localhost", port: 56784, db: 0)
    redis.get("user:access_token:#{access_token}")
  end
end
