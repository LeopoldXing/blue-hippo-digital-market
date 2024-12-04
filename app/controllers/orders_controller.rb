class OrdersController < ApplicationController
  include Authentication
  before_action :authenticate_user

  def create_checkout_session
    payload_order_id = params[:payloadOrderId]
    product_id_list = params[:productIdList] || []

    if payload_order_id.blank? || product_id_list.blank?
      render json: { errorMessage: "payloadOrderId and productIdList are required" }, status: :bad_request
      return
    end

    product_ids = product_id_list.map(&:to_i)
    user = @current_user
    products = Product.where(id: product_ids)

    if products.size != product_ids.size
      missing_ids = product_ids - products.pluck(:id)
      render json: { errorMessage: "Products not found: #{missing_ids.join(', ')}" }, status: :not_found
      return
    end

    cart_total = products.sum(&:price)

    # Query tax information
    province_code = user.province
    tax_info = CanadaSalesTax.find_by(province_code: province_code)
    tax_type = tax_info ? tax_info.tax_type.to_s.downcase : ""
    hst = 0
    gst = 0
    pst = 0

    case tax_type
    when "hst"
      hst_rate = tax_info ? tax_info.hst_rate * 0.01 : 0.01
      hst = hst_rate * cart_total
    when "gst"
      gst_rate = tax_info ? tax_info.gst_rate * 0.01 : 0.01
      gst = gst_rate * cart_total
    when "gst+pst"
      pst_rate = tax_info ? tax_info.pst_rate * 0.01 : 0.01
      gst_rate = tax_info ? tax_info.gst_rate * 0.01 : 0.01
      pst = pst_rate * cart_total
      gst = gst_rate * cart_total
    end

    # Step 1: create order
    order = Order.new(
      payload_id: payload_order_id,
      user: user,
      is_paid: false,
      tax_type: tax_type,
      hst: hst,
      gst: gst,
      pst: pst,
      created_by: user.id,
      updated_by: user.id,
      products: products
    )

    if order.save
      # Order saved successfully
    else
      Rails.logger.error "Order save failed: #{order.errors.full_messages}"
      render json: { errorMessage: order.errors.full_messages.join(", ") }, status: :unprocessable_entity
      return
    end

    # Step 2: get Stripe price IDs
    price_ids = products.pluck(:price_id)

    if price_ids.any?(&:blank?)
      render json: { errorMessage: "One or more products do not have a valid price ID" }, status: :unprocessable_entity
      return
    end

    # Step 3: construct line items
    line_items = price_ids.map do |price_id|
      {
        price: price_id,
        quantity: 1
      }
    end

    # Calculate total tax amount in cents
    tax_amount_cents = ((gst + hst + pst) * 100).to_i

    # Add tax as a line item using price_data
    if tax_amount_cents > 0
      line_items.push({
                        price_data: {
                          currency: 'cad',
                          product_data: {
                            name: 'Tax'
                          },
                          unit_amount: tax_amount_cents
                        },
                        quantity: 1
                      })
    end

    # Step 4: insert metadata
    metadata = {
      "order_id" => order.id.to_s
    }

    # Step 5: create Checkout Session
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    success_url = "#{ENV['FRONTEND_URL']}/thank-you?orderId=#{order.id}&loggedIn=true"
    cancel_url = "#{ENV['FRONTEND_URL']}/checkout?loggedIn=true"

    begin
      session = Stripe::Checkout::Session.create(
        payment_method_types: ["card", "alipay", "wechat_pay"],
        mode: "payment",
        line_items: line_items,
        payment_intent_data: {
          metadata: metadata
        },
        payment_method_options: {
          wechat_pay: {
            client: "web"
          }
        },
        success_url: success_url,
        cancel_url: cancel_url
      )
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      render json: { errorMessage: e.message }, status: :unprocessable_entity
      return
    end

    # Step 6: return Checkout Session URL
    render plain: session.url, status: :ok
  end
end
