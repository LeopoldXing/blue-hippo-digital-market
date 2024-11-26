# app/controllers/users_controller.rb
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
end