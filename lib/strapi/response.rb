# frozen_string_literal: true

module Strapi
  # The parsed response returned from the Strapi API
  class Response
    attr_reader :parsed_response

    def initialize(faraday_response)
      @parsed_response = faraday_response.body
      return if faraday_response.success?

      raise Error, error
    end

    %w[data error meta].each do |method|
      define_method(method) do
        @parsed_response[method]
      end
    end
  end
end
