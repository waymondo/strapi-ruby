module Strapi
  class Error < StandardError
    attr_reader :status, :name, :message, :details

    def initialize(hash = {})
      super
      @status = hash["status"]
      @name = hash["name"]
      @message = hash["message"]
      @details = hash["details"]
    end
  end
end
