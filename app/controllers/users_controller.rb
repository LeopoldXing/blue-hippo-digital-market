require "redis"

class UsersController < ApplicationController
  include Authentication
  before_action :authenticate_user, only: [:get_current_user, :sign_out]

  # GET /api/user
  def get_current_user
    if @current_user
      render json: {
        id: @current_user.id,
        email: @current_user.email,
        username: @current_user.username,
        role: @current_user.role,
        createdAt: @current_user.created_at,
        updatedAt: @current_user.updated_at
      }, status: :ok
    else
      render json: { apiPath: "/api/user", errorCode: "UNAUTHORIZED", errorMessage: "Invalid Token, please sign in.", errorTime: [] }, status: :unauthorized
    end
  end

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

      # query user's cart items
      cart_items = Cart.where(user_id: user.id).includes(product: :product_images)
      products = cart_items.map(&:product)

      product_fields = [
        :id,
        :payload_id,
        :name,
        :description,
        :price,
        :price_id,
        :stripe_id,
        :category,
        :product_file_url,
        :approved_for_sale,
        :created_at,
        :updated_at,
        :created_by,
        :updated_by
      ]

      product_image_fields = [
        :id,
        :payload_id,
        :url,
        :filename,
        :filesize,
        :width,
        :height,
        :mime_type,
        :file_type,
        :created_at,
        :updated_at,
        :created_by,
        :updated_by
      ]

      product_list = products.map do |product|
        product_json = product.as_json(
          only: product_fields,
          include: {
            product_images: {
              only: product_image_fields
            }
          }
        )
        product_json.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
        if product_json['productImages']
          product_json['productImages'].each do |image|
            image.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
          end
        end

        product_json
      end

      # query tax information
      province_code = user.province
      tax_info = CanadaSalesTax.find_by(province_code: province_code)
      tax_type = tax_info ? tax_info.tax_type.to_s.downcase : ""
      tax_rate = 0

      case tax_type
      when "hst"
        tax_rate = tax_info ? tax_info.hst_rate * 0.01 : 0.01
      when "gst"
        tax_rate = tax_info ? tax_info.gst_rate : 0.01
      when "gst+pst"
        tax_rate = tax_info ? ((tax_info.gst_rate || 0) + (tax_info.pst_rate || 0)) * 0.01 : 0.01
      end

      render json: {
        accessToken: access_token,
        productList: product_list,
        taxType: tax_type,
        taxRate: tax_rate
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
    user_id = @current_user.id
    redis = ::Redis.new(host: "localhost", port: 56784, db: 0)
    access_token = redis.get("user:id:#{user_id}")
    redis.del("user:id:#{user_id}")
    redis.del("user:access_token:#{access_token}")

    render json: { message: "Sign out successful" }, status: :ok
  end

  private

  def verify_password(user, password)
    hashed_password = Digest::SHA256.hexdigest(password + user.salt)
    hashed_password == user.password_hash
  end
end