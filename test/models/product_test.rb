require "test_helper"

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
    
  #   assert true
  # end

  test "should not save Product" do
    product = Product.new
    
    assert product.invalid?
    assert product.errors[:product_name].any?
  end

  test "should not save without image" do
    product = Product.new(product_name: "X",description: "sgahghasghasg",price:2.0,vendor:"Y")
    assert_not product.save
    
    assert product.errors[:image].any?
    assert product.errors[:product_name].none?
    assert product.errors[:description].none?
    assert product.errors[:price].none?
  end
  test "should not accept negative price" do
    product = Product.new(product_name: "X",description: "sgahghasghasg",price:-2.0,vendor:"Y")
    
    assert_not product.save
    
    assert product.errors[:price].any?
  end
  test "should not accept short description" do
    product = Product.new(product_name: "X",description: "sgahg",price:2.0,vendor:"Y")
    
    assert_not product.save
    
    assert product.errors[:description].any?
  end
  test "sucess all" do
    product=Product.last
    
    assert product.errors[:image].none?
    assert product.errors[:product_name].none?
    assert product.errors[:description].none?
    assert product.errors[:price].none?
    
  end
  

end
