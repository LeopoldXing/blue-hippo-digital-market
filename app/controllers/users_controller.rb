require "redis"

class UsersController < ApplicationController
  # POST /api/user/sign-up
  def sign_up
    user_params = params.permit(
      :email,
      :password,
      :province,
      :addressLine1,
      :addressLine2,
      :postalCode,
      :payloadId,
      :username,
      :role,
      productIdList: []
    )

    if User.exists?(email: user_params[:email])
      render json: {
        apiPath: request.path,
        errorCode: 400,
        errorMessage: "User with this email already exists",
        errorTime: Time.current.iso8601
      }, status: :bad_request
      return
    end

    password = user_params.delete(:password)
    salt = SecureRandom.hex(16)
    password_hash = Digest::SHA256.hexdigest(password + salt)

    mapped_params = {
      email: user_params[:email],
      password_hash: password_hash,
      salt: salt,
      province: user_params[:province],
      address_line_1: user_params[:addressLine1],
      address_line_2: user_params[:addressLine2],
      postal_code: user_params[:postalCode],
      payload_id: user_params[:payloadId],
      username: user_params[:username] || user_params[:email],
      role: user_params[:role] || "user",
      verified: false,
      locked: false,
      lock_until: nil,
      created_by: "system",
      updated_by: "system"
    }

    user = User.new(mapped_params)

    if user.save
      render json: {
        success: true,
        email: user.email
      }, status: :created
    else
      render json: {
        apiPath: request.path,
        errorCode: 422,
        errorMessage: user.errors.full_messages.join(", "),
        errorTime: Time.current.iso8601
      }, status: :unprocessable_entity
    end
  end

  # POST /api/user/sign-in
  def sign_in
    email = params[:email]
    password = params[:password]
    product_id_list = params[:productIdList] || []

    user = User.find_by(email: email)

    if user && verify_password(user, password)
      # save session into redis
      access_token = SecureRandom.hex(32)
      redis = ::Redis.new(host: "localhost", port: 56784, db: 0)
      redis.set("user:access_token:#{access_token}", user.id)
      redis.set("user:id:#{user.id}", access_token)

      # merge_cart_items(user, product_id_list)

      render json: {
        accessToken: access_token,
        productList: product_id_list
      }, status: :ok
    else
      render json: {
        apiPath: request.path,
        errorCode: 401,
        errorMessage: "Authentication failed",
        errorTime: Time.current.iso8601
      }, status: :unauthorized
    end
  end

  # POST /api/user/sign-out
  def sign_out
    if session[:user_id]
      user_id = session[:user_id]
      redis = ::Redis.new(host: "localhost", port: 56784, db: 0)
      access_token = redis.get("user:id:#{user_id}")
      redis.del("user:id:#{user_id}")
      redis.del("user:access_token:#{access_token}")

      render json: { message: "Sign out successful" }, status: :ok
    else
      render json: { error: "User not signed in" }, status: :unauthorized
    end
  end

  private

  def verify_password(user, password)
    hashed_password = Digest::SHA256.hexdigest(password + user.salt)
    hashed_password == user.password_hash
  end
end