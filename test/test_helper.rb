# frozen_string_literal: true

ENV['STRAPI_HOST_URL'] = 'http://localhost:1337'
ENV['STRAPI_IDENTIFIER'] = 'admin@example.com'
ENV['STRAPI_PASSWORD'] = 'password'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'strapi'
require 'debug'
require 'webmock/minitest'
require 'minitest/autorun'
