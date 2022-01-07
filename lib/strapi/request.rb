# frozen_string_literal: true

module Strapi
  # A convenience wrapper around Faraday to make a request to the Strapi API
  class Request
    ALLOWED_PARAM_KEYS = %i[sort filters populate fields pagination publicationState locale].freeze
    REQUEST_VERBS_WITHOUT_BODIES = %i[get head delete trace].freeze

    class << self
      %i[get head delete trace post put patch].each do |method|
        define_method(method) do |path, args = {}|
          validate_query_params(args) if REQUEST_VERBS_WITHOUT_BODIES.include?(method)

          Response.new(
            Connection.instance.send(method, path, args) do |f|
              f.headers = {
                'Authorization' => "bearer #{Connection.jwt_token}"
              }
            end
          )
        end
      end

      private

      def validate_query_params(params)
        unallowed_query_params = params.keys - ALLOWED_PARAM_KEYS
        return unless unallowed_query_params.size.positive?

        raise(
          Error,
          'message' => "Unallowed query params - #{unallowed_query_params.join(', ')}"
        )
      end
    end
  end
end
