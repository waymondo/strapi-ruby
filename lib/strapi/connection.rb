# frozen_string_literal: true

module Strapi
  # The singleton class representing the Faraday connection to Strapi
  class Connection
    class << self
      def instance
        @instance ||= Faraday::Connection.new("#{ENV['STRAPI_HOST_URL']}/api", options)
      end

      def options
        return unless (api_token = ENV['STRAPI_API_TOKEN'].presence)

        {
          headers: {
            'Authorization' => "bearer #{api_token}"
          }
        }
      end
    end
  end
end
