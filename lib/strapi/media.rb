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
      ENV['STRAPI_HOST_URL'] + @attributes['url']
    end
  end
end
