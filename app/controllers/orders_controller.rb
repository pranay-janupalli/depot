class OrdersController < ApplicationController
  include CurrentCart
  before_action :set_order, only: %i[ show edit update destroy ]
  
  before_action :set_cart, only: [:new, :create, :update]
  before_action :ensure_cart_isnt_empty, only: :new

  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order=@cart.order
    if @order.nil?
      @order = Order.new
    else
      redirect_to edit_order_path(@order.id)
    end
  end

  # GET /orders/1/edit
  def edit
    @order=Order.find(params[:id])
  end

  # POST /orders or /orders.json
  def create
    @order = @cart.build_order(order_params)
    

    respond_to do |format|
      if @order.save
        @cart.line_items.each do |line_item|
          @order.order_items.create!(name: line_item.product.product_name,quantity: line_item.quantity,price: line_item.product.price)
        end
        @total=(@order.order_items.sum { |x| x['quantity']*x['price'] } ) * 100 
        
        begin
          customer=Stripe::Customer.create({email: params[:stripeEmail],source: params[:stripeToken]})
          charge=Stripe::Charge.create({customer: customer.id,amount: @total.to_i,currency: 'inr' })
          rescue Stripe::CardError => e
            return redirect_to edit_order_path(@order)
        end
        @order.payments.create!(chargeid: charge.id,status: charge.status,amount: (charge.amount)/100 )
        if charge.status == "succeeded"
          session[:cart_id]=nil
          OrderMailer.recieved(@order).deliver_later
          return redirect_to orders_success_path
        elsif charge.status == "failed"
          return redirect_to edit_order_path(@order)
          
        

        end
        
      
        format.html { return redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    @order=Order.find(params[:id])
    respond_to do |format|
      if @order.update(order_params)
        @order.order_items.destroy_all
        @cart.line_items.each do |line_item|
          @order.order_items.create!(name: line_item.product.product_name,quantity: line_item.quantity,price: line_item.product.price)
        end
        @total=(@order.order_items.sum { |x| x['quantity']*x['price'] } ) * 100 
        
        begin
          customer=Stripe::Customer.create({email: params[:stripeEmail],source: params[:stripeToken]})
          charge=Stripe::Charge.create({customer: customer.id,amount: @total.to_i,currency: 'inr' })
          rescue Stripe::CardError => e
            return redirect_to edit_order_path(@order)
        end
        if charge.status == "succeeded"
          session[:cart_id]=nil
          OrderMailer.recieved.deliver_later
          return redirect_to orders_success_path
        elsif charge.status == "failed"
          return redirect_to edit_order_path(@order)

        end

        format.html { return redirect_to @order, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def success

  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:name, :address, :email, :pay_type)
    end

    def ensure_cart_isnt_empty
      if @cart.line_items.empty?
        redirect_to root_path
      end
    end
end
