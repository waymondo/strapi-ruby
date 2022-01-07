# frozen_string_literal: true

require 'test_helper'
require 'webmock_support'

class ConnectionTest < Minitest::Test
  include WebmockSupport

  def test_connection_can_request_jwt_token
    jwt_token = Strapi::Connection.jwt_token
    assert_equal(
      jwt_token,
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'\
      'eyJpZCI6MSwiaWF0IjoxNTc2OTM4MTUwLCJleHAiOjE1Nzk1MzAxNTB9.'\
      'UgsjjXkAZ-anD257BF7y1hbjuY3ogNceKfTAQtzDEsU'
    )
  end
end
