# frozen_string_literal: true

module Strapi
  # The class for defining a Ruby class that represents a Strapi Content-Type
  class ContentType
    attr_reader :id, :attributes

    def initialize(response_data)
      @id = response_data['id']
      @attributes = response_data['attributes'].transform_keys(&:underscore)
    end

    def created_at
      datetime_from_timestamp 'created_at'
    end

    def updated_at
      datetime_from_timestamp 'updated_at'
    end

    def published_at
      datetime_from_timestamp 'published_at'
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    private

    def datetime_from_timestamp(key)
      return unless (timestamp = @attributes[key])

      DateTime.parse timestamp
    end

    def strapi_attr_value(attr, options)
      value = @attributes[attr.to_s]
      return value unless (content_type = options[:content_type])

      content_type_class = content_type.is_a?(String) ? content_type.constantize : content_type
      if (data = value['data']).is_a?(Array)
        data.map do |entry|
          content_type_class.new(entry)
        end
      else
        content_type_class.new(data)
      end
    end

    class << self
      def plural_id(name)
        @_plural_id = name
      end

      def field(attr, options = {})
        define_method attr do
          strapi_attr_value(attr, options)
        end

        define_method "#{attr}=" do |value|
          attributes[attr.to_s] = value
        end
      end

      def find(id, query_hash = {})
        new Request.get("#{_plural_id}/#{id}?#{query_hash.to_query}").data
      end

      def all(query_hash = {})
        get_list(query_hash)
      end

      def where(query_hash)
        get_list(query_hash)
      end

      private

      def get_list(query_hash)
        strapi_filter_query(query_hash).map do |result|
          new result
        end
      end

      def strapi_filter_query(query_hash)
        Request.get("#{_plural_id}?#{query_hash.to_query}").data
      end

      def _plural_id
        @_plural_id ||= to_s.demodulize.tableize.dasherize
      end
    end
  end
end
