require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @product = Product.last
    
  end
  test "should get index" do
    get product_url(@product.id)
    assert_response :success
  end
end
