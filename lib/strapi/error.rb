# frozen_string_literal: true

module Strapi
  # An error raised within the Strapi ruby library
  class Error < StandardError
    attr_reader :status, :name, :message, :details

    def initialize(hash = {})
      super
      @status = hash['status']
      @name = hash['name']
      @message = hash['message']
      @details = hash['details']
    end
  end
end
