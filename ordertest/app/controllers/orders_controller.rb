class OrdersController < ApplicationController

  def index
    @orders = Order.all
  end

  def show
@order = Order.find params[:id]
  end


  def import
    Order.import(params[:file])
    redirect_to root_url, notice: "Orders imported"
  end

end