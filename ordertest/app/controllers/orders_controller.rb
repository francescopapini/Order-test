class OrdersController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find params[:id]
    json_order = { 
      order: { id: @order.id, customer: { id: @order.customer_id }},
      supplier: { id: @order.supplier_id },
      date: @order.order_date.strftime("%d-%m-%Y"),
      total_order_value: {local_currency_code: @order.currency, local_value: number_to_currency(@order.total_order_value_pence, unit: ""), value: number_to_currency(@order.convert_order_to_historical_rate(@order.total_order_value_pence, "GBP", @order.order_date), unit: "")}
    } 
    
    respond_to do |format|
      format.html 
      format.json { render json: JSON.pretty_generate(json_order) }
    end
  end

  def new
  end

  def import
    if params[:file]
      orders_number = Order.all.size
      Order.import_file(params[:file])
      new_orders_number = Order.all.size
      if orders_number == new_orders_number
        redirect_to new_order_path, notice: "No New Orders To Upload, Please Try Another File"
      else
        redirect_to root_url, notice: "Orders Uploaded!"
      end
    else
      redirect_to new_order_path, notice: "No File To Import, Please Add File"
    end
  end

end