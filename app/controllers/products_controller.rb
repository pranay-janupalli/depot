class ProductsController < ApplicationController
  def index
    @products = Product.all
  end
  def show
    @product = Product.find(params[:id])
  end
  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product
    else
      render :new
    end
  end
  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      redirect_to @product
    else
      render :edit
    end
  end
  def destroy
    @article = Product.find(params[:id])
    @article.destroy

    redirect_to root_path
  end
  private
    def product_params
      params.require(:product).permit(:product_name, :description, :price, :vendor, :image)
    end
end
