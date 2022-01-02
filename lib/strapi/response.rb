module Strapi
  class Response
    attr_reader :parsed_response

    def initialize(faraday_response)
      @parsed_response = Oj.load(faraday_response.body)
      return if faraday_response.success?

      raise Error, error
    end

    %w[data error].each do |method|
      define_method(method) do
        @parsed_response[method]
      end
    end
  end
end
