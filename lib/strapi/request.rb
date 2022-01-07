# frozen_string_literal: true

module Strapi
  # A convenience wrapper around Faraday to make a request to the Strapi API
  class Request
    class << self
      %i[get head delete trace post put patch].each do |method|
        define_method(method) do |*args|
          Response.new(
            Connection.instance.send(method, *args) do |f|
              f.headers = {
                'Authorization' => "bearer #{Connection.jwt_token}"
              }
            end
          )
        end
      end
    end
  end
end
