module Strapi
  class Connection
    class << self
      def instance
        @instance ||= Faraday::Connection.new(ENV["STRAPI_HOST_URL"], options)
      end

      def api_token
        ENV["STRAPI_API_TOKEN"].presence
      end

      def options
        return unless api_token

        { headers: { "Authorization" => "bearer #{api_token}" } }
      end
    end
  end
end
