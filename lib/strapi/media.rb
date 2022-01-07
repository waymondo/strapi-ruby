# frozen_string_literal: true

module Strapi
  # The Content-Type for uploaded Strapi photos, videos, and files
  class Media < ContentType
    field :name
    field :alternative_text
    field :caption
    field :width
    field :height
    field :formats # TODO: attribute value
    field :hash
    field :ext
    field :mime
    field :size
    field :url
    field :preview_url
    field :preview_provider
    field :provider_metadata

    def url
      return unless (url_string = @attributes[:url].presence)

      if url_string.include?('//')
        url_string
      else
        ENV['STRAPI_HOST_URL'] + url_string
      end
    end
  end
end
