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

  class ProductCategory
    include Strapi::Model
    plural_id "product-categories"
    field :Title
    field :Position
    field :Slug
  end

  def test_it_can_query_models
    product_category = ProductCategory.all.first
    refute_nil product_category.title
    refute_nil product_category.position
    refute_nil product_category.slug
  end
end
