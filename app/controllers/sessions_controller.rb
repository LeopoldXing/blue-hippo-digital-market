class SessionsController < ApplicationController
  # （sign-in）
  def create
    email = params[:email]
    password = params[:password]
    product_id_list = params[:productIdList] || []

    user = User.find_by(email: email)

    if user && verify_password(user, password)
      # （access token）
      access_token = SecureRandom.hex(32)
      store_session_in_redis(user.id, access_token)

      # merge_cart_items(user, product_id_list)

      render json: { accessToken: access_token }, status: :ok
    else
      render json: { errorMessage: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # （sign-out）
  def destroy
    access_token = request.headers['Authorization']&.split(' ')&.last

    if access_token
      user_id = get_user_id_from_token(access_token)
      if user_id
        delete_session_from_redis(user_id, access_token)
        render json: { message: 'Signed out successfully' }, status: :ok
      else
        render json: { errorMessage: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { errorMessage: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def verify_password(user, password)
    hashed_password = Digest::SHA256.hexdigest(password + user.salt)
    hashed_password == user.password_hash
  end

  def store_session_in_redis(user_id, access_token)
    redis = Redis.new(host: "localhost", port: 56784, db: 0)
    redis.set("user:access_token:#{access_token}", user_id, ex: 90 * 60)
    redis.set("user:id:#{user_id}:access_token", access_token, ex: 90 * 60)
  end

  def get_user_id_from_token(access_token)
    redis = Redis.new(host: "localhost", port: 56784, db: 0)
    redis.get("user:access_token:#{access_token}")
  end

  def delete_session_from_redis(user_id, access_token)
    redis = Redis.new(host: "localhost", port: 56784, db: 0)
    redis.del("user:access_token:#{access_token}")
    redis.del("user:id:#{user_id}:access_token")
  end

  def merge_cart_items(user, product_id_list)
    product_id_list.each do |product_id|
      product = Product.find_by(payload_id: product_id)
      if product
        user.carts.find_or_create_by(product_id: product.id)
      end
    end
  end
end
