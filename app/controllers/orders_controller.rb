class OrdersController < ApplicationController
  include Authentication
  before_action :authenticate_user, except: [:get_tax]

  def get_tax
    user_province_code = @current_user.province

  end
end
