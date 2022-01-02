module Strapi
  class ContentType
    attr_reader :id, :attributes

    def initialize(response_data)
      @id = response_data["id"]
      @attributes = response_data["attributes"].transform_keys(&:underscore)
    end

    def created_at
      DateTime.parse @attributes["created_at"]
    end

    def updated_at
      DateTime.parse @attributes["updated_at"]
    end

    def ==(other)
      id == other.id
    end

    private

    def strapi_attr_value(attr, options)
      value = @attributes[attr.to_s]
      return value unless (content_type = options[:content_type])

      content_type.new(value["data"])
    end

    # def strapi_apply_attribute_options(value, options)
    #   options.each_pair do |key, option_value|
    #     case key
    #     when :markdown
    #       # TODO: markdown support
    #       return Kramdown::Document.new(value).to_html if value.present?
    #     when :content_type
    #       return strapi_convert_to_content_type(value, option_value, options[:group])
    #     when :media
    #       return Media.new(value)
    #     end
    #   end
    #   value
    # end

    class << self
      def plural_id(name)
        @_plural_id = name
      end

      def _plural_id
        @_plural_id ||= to_s.demodulize.dasherize.pluralize
      end

      def field(attr, options = {})
        define_method attr do
          strapi_attr_value(attr, options)
        end

        define_method "#{attr}=" do |value|
          attributes[attr.to_s] = value
        end
      end

      def find(id)
        new Request.get("#{_plural_id}/#{id}").data
      end

      def find_by(query_hash)
        hash = strapi_filter_query(query_hash)[0]
        raise NotFoundError unless hash

        new(hash)
      end

      def all(query_hash = { populate: "*" })
        strapi_filter_query(query_hash).map do |result|
          new result
        end
      end

      def where(query_hash)
        strapi_filter_query(query_hash).map do |result|
          new result
        end
      end

      def strapi_filter_query(query_hash)
        Request.get("#{_plural_id}?#{query_hash.to_query}").data
      end
    end
  end
end
