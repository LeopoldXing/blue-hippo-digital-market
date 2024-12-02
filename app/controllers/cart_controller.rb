class CartController < ApplicationController
  include Authentication
  before_action :authenticate_user

  # GET /api/cart
  def get_cart
    cart_items = @current_user.carts.includes(product: :product_images)
    products = cart_items.map(&:product)

    render json: products.as_json(include: { product_images: { only: [:url, :file_type] } }), status: :ok
  end

  # POST /api/cart/:product_id
  def create
    product_id = params[:product_id]
    product = Product.find_by(id: product_id)

    if product.nil?
      render json: { errorMessage: "Product not found" }, status: :not_found
      return
    end

    if @current_user.carts.exists?(product_id: product_id)
      render json: { errorMessage: "Product is already in your cart" }, status: :unprocessable_entity
      return
    end

    cart_item = @current_user.carts.build(product: product, created_by: @current_user.id, updated_by: @current_user.id)

    if cart_item.save
      render json: { message: "Product added to cart successfully" }, status: :ok
    else
      render json: { errorMessage: cart_item.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # DELETE /api/cart/:product_id
  def destroy
    product_id = params[:product_id]
    cart_item = @current_user.carts.find_by(product_id: product_id)

    if cart_item.nil?
      render json: { errorMessage: "Product not found in cart" }, status: :not_found
      return
    end

    cart_item.destroy
    render json: { message: "Product removed from cart successfully" }, status: :ok
  end

  # DELETE /api/cart/clear
  def clear
    @current_user.carts.destroy_all
    render json: { message: "Cart cleared successfully" }, status: :ok
  end
end
