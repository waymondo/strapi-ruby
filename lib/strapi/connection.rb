# frozen_string_literal: true

module Strapi
  # The singleton class representing the Faraday connection to Strapi
  class Connection
    class << self
      def instance
        @instance ||= Faraday::Connection.new("#{ENV['STRAPI_HOST_URL']}/api") do |f|
          f.request :json
          f.response :json
          f.adapter :net_http
        end
      end

      def jwt_token
        @jwt_token ||= instance.post(
          'auth/local',
          identifier: ENV['STRAPI_IDENTIFIER'],
          password: ENV['STRAPI_PASSWORD']
        ).body['jwt']
      end
    end
  end
end
