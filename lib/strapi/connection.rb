module Strapi
  class Connection
    def self.instance
      @instance ||= Faraday::Connection.new(
        ENV["STRAPI_HOST_URL"],
        headers: { "Authorization" => "bearer #{ENV["STRAPI_API_TOKEN"]}" }
      )
    end
  end
end
