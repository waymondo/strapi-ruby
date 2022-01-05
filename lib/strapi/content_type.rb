# frozen_string_literal: true

module Strapi
  # The class for defining a Ruby class that represents a Strapi Content-Type
  class ContentType
    attr_reader :id, :attributes, :deleted

    def initialize(attributes = {})
      @attributes = attributes.symbolize_keys
    end

    %w[created_at updated_at published_at].each do |method|
      define_method(method) do
        datetime_from_timestamp method
      end
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def save(query_hash = {})
      return if deleted

      response = id ? update_request(query_hash) : create_request(query_hash)
      entry = self.class.send(:new_from_response, response)
      tap do
        @attributes = entry.attributes
        @id = entry.id
      end
    end

    def delete(query_hash = {})
      Request.delete("#{self.class.send(:_plural_id)}/#{id}?#{query_hash.to_query}")
      @attributes = {}
      @id = nil
      @deleted = true
      nil
    end

    private

    def create_request(query_hash)
      Request.post(
        "#{self.class.send(:_plural_id)}?#{query_hash.to_query}",
        data: attributes.slice(*self.class.fields)
      ).data
    end

    def update_request(query_hash)
      Request.put(
        "#{self.class.send(:_plural_id)}/#{id}?#{query_hash.to_query}",
        data: attributes.slice(*self.class.fields)
      ).data
    end

    def datetime_from_timestamp(key)
      return unless (timestamp = @attributes[key])

      DateTime.parse timestamp
    end

    def strapi_attr_value(attr, options)
      value = @attributes[attr]
      return value unless (content_type = options[:content_type])

      content_type_class = content_type.is_a?(String) ? content_type.constantize : content_type
      if (data = value['data']).is_a?(Array)
        data.map do |entry|
          content_type_class.send(:new_from_response, entry)
        end
      else
        content_type_class.send(:new_from_response, data)
      end
    end

    class << self
      attr_reader :fields

      def plural_id(name)
        @_plural_id = name
      end

      def field(attr, options = {})
        @fields = [] if fields.nil?
        fields << attr

        define_method attr do
          strapi_attr_value(attr, options)
        end

        define_method "#{attr}=" do |value|
          attributes[attr] = value
        end
      end

      def find(id, query_hash = {})
        new_from_response Request.get("#{_plural_id}/#{id}?#{query_hash.to_query}").data
      end

      def all(query_hash = {})
        get_list(query_hash)
      end

      def where(query_hash)
        get_list(query_hash)
      end

      def create(attributes, query_hash = {})
        new(attributes).save(query_hash)
      end

      private

      def new_from_response(response)
        new(response['attributes'].transform_keys(&:underscore)).tap do |entry|
          entry.instance_variable_set('@id', response['id'])
        end
      end

      def get_list(query_hash)
        Request.get("#{_plural_id}?#{query_hash.to_query}").data.map do |result|
          new_from_response result
        end
      end

      def _plural_id
        @_plural_id ||= to_s.demodulize.tableize.dasherize
      end
    end
  end
end
