# frozen_string_literal: true

require 'test_helper'

class StrapiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Strapi::VERSION
  end

  def test_it_can_make_a_request
    response = Strapi::Request.get('product-categories')
    assert_instance_of Strapi::Response, response
  end
end
