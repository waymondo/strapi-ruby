# frozen_string_literal: true

require "test_helper"

class StrapiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Strapi::VERSION
  end

  def test_it_can_make_a_request
    response = Strapi::Request.get("product-categories")
    assert_instance_of Strapi::Response, response
  end

  class ProductCategory < Strapi::ContentType
    plural_id "product-categories"
    field :title
    field :position
    field :slug
  end

  class Product < Strapi::ContentType
    field :product_category, content_type: ProductCategory
  end

  def test_it_can_query_models
    product_category = ProductCategory.all.first
    refute_nil product_category.title
    refute_nil product_category.position
    refute_nil product_category.slug
    product = Product.all.first
    assert_equal product.product_category, product
    refute_nil product.title
    refute_nil product.position
    refute_nil product.slug
  end
end
