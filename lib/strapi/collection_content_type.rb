# frozen_string_literal: true

module Strapi
  class CollectionContentType
    attr_reader :data, :pagination

    def initialize(data, meta)
      @data = data
      @pagination = Pagination.new(meta['pagination'])
    end

    def has_next_page?
      pagination.page < pagination.page_count
    end

    private

    def method_missing(name, *args, &block)
      data.send(name, *args, &block)
    end
  end
end
