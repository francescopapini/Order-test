class OrdersController < ApplicationController

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find params[:id]
    json_order = { 
                   order: { id: @order.id, customer: { id: @order.customer_id }},
                   supplier: { id: @order.supplier_id },
                   date: @order.order_date.strftime("%d-%m-%Y"),
                   total_order_value: {local_currency_code: @order.currency, local_value: @order.total_order_value_pence.to_s, value: @order.convert_order_to_gbp_current_rate(@order.total_order_value_pence).to_s}
                 } 
    respond_to do |format|
      format.html 
      format.json { render json: JSON.pretty_generate(json_order) }

    end
  end


  def import
    Order.import(params[:file])
    redirect_to root_url, notice: "Orders imported"
  end

end