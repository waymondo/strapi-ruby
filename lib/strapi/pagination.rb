# frozen_string_literal: true

module Strapi
  class Pagination
    attr_reader :page, :page_size, :page_count, :total

    def initialize(pagination)
      @page = pagination['page']
      @page_size = pagination['pageSize']
      @page_count = pagination['pageCount']
      @total = pagination['total']
    end
  end
end
