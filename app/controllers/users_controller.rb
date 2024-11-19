class UsersController < ApplicationController
  protect_from_forgery with: :null_session

  def sign_up
    payload_id = params[:payloadId]
    email = params[:email]
    password = params[:password]
    role = params[:role]
    product_id_list = params[:productIdList]

    user = User.new(
      payload_id: payload_id,
      email: email,
      password_hash: hash_password(password),
      role: role,
      created_by: 'system',
      updated_by: 'system'
    )

    if user.save
      if product_id_list.present?
        products = Product.where(id: product_id_list)
        user.products << products
      end

      render json: { message: 'User created successfully', user_id: user.id }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def hash_password(password)
    BCrypt::Password.create(password)
  end
end
