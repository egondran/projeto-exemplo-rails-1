class HomeController < ApplicationController
  def index
    @categories = Category.all
    @products_count = Product.count
    @categories_count = Category.count
    @featured_products = Product.order(Arel.sql("RAND()")).limit(6)
  end
end
