class OrdersController < ApplicationController
  include Authentication
  before_action :authenticate_user

  def create_checkout_session
    # 获取参数
    payload_order_id = params[:payloadOrderId]
    product_id_list = params[:productIdList] || []

    # 参数验证
    if payload_order_id.blank? || product_id_list.blank?
      render json: { errorMessage: "payloadOrderId and productIdList are required" }, status: :bad_request
      return
    end

    # 确保 product_id_list 是整数数组
    product_ids = product_id_list.map(&:to_i)

    # 获取当前用户
    user = @current_user

    # Step 1: 创建订单
    order = Order.new(
      payload_id: payload_order_id,
      user: user,
      is_paid: false
    )

    # 关联产品到订单
    products = Product.where(id: product_ids)

    # 检查是否找到所有产品
    if products.size != product_ids.size
      missing_ids = product_ids - products.pluck(:id)
      render json: { errorMessage: "Products not found: #{missing_ids.join(', ')}" }, status: :not_found
      return
    end

    order.products = products

    # 保存订单
    if order.save
      # 订单保存成功
    else
      # 处理错误
      render json: { errorMessage: order.errors.full_messages.join(", ") }, status: :unprocessable_entity
      return
    end

    # Step 2: 获取产品的 Stripe 价格 ID
    price_ids = products.pluck(:price_id)

    # 检查所有产品是否都有价格 ID
    if price_ids.any?(&:blank?)
      render json: { errorMessage: "One or more products do not have a valid price ID" }, status: :unprocessable_entity
      return
    end

    # Step 3: 构建 line items
    line_items = price_ids.map do |price_id|
      {
        price: price_id,
        quantity: 1
      }
    end

    # Step 4: 构建元数据
    metadata = {
      'order_id' => order.id.to_s
    }

    # Step 5: 创建 Checkout Session
    Stripe.api_key = ENV['STRIPE_SECRET_KEY'] # 确保已设置环境变量

    success_url = "#{ENV['FRONTEND_URL']}/thank-you?orderId=#{order.id}"
    cancel_url = "#{ENV['FRONTEND_URL']}/checkout?loggedIn=true"

    begin
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card', 'alipay', 'wechat_pay'],
        mode: 'payment',
        line_items: line_items,
        payment_intent_data: {
          metadata: metadata
        },
        payment_method_options: {
          wechat_pay: {
            client: 'web'
          }
        },
        success_url: success_url,
        cancel_url: cancel_url
      )
    rescue Stripe::StripeError => e
      # 处理错误
      render json: { errorMessage: e.message }, status: :unprocessable_entity
      return
    end

    # Step 6: 返回 Checkout Session 的 URL
    render json: { url: session.url }, status: :ok
  end
end
