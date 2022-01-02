module Strapi
  module Model
    extend ActiveSupport::Concern

    included do
      attr_reader :_data
    end

    def initialize(hash = nil)
      @_data = hash || {}
    end

    def attributes
      _data["attributes"].map do |key, value|
        [key, send(key)]
      rescue NoMethodError
        [key, value]
      end.to_h
    end

    def id
      _data["id"]
    end

    private

    def strapi_attr_value(attr, options)
      value = _data.dig("attributes", attr.to_s)
      case value
      when Array
        value.map do |val|
          strapi_apply_attribute_options(val, options)
        end
      else
        strapi_apply_attribute_options(value, options)
      end
    end

    def strapi_apply_attribute_options(value, options)
      options.each_pair do |key, option_value|
        case key
        when :markdown
          # TODO: markdown support
          return Kramdown::Document.new(value).to_html if value.present?
        when :content_type
          return strapi_convert_content_type(value, option_value, options[:group])
        when :media
          return Media.new(value)
        end
      end
      value
    end

    def strapi_convert_content_type(value, option_value, group)
      if group
        return [] unless value

        value[option_value.class.strapi_content_type_name].map { |hash| option_value.new(hash) }
      elsif value
        option_value.new(value)
      end
    end

    class_methods do
      attr_reader :strapi_content_type_name

      def plural_id(name)
        @strapi_content_type_name = name
      end

      def field(symbol_or_array)
        attr, options = case symbol_or_array
                        when Array
                          [symbol_or_array[0], symbol_or_array[1]]
                        else
                          [symbol_or_array, {}]
                        end

        [attr, ActiveSupport::Inflector.underscore(attr)].uniq.each do |inner_attr|
          define_method inner_attr do
            strapi_attr_value(attr, options)
          end
        end

        define_method "#{attr}=" do |value|
          _fields[attr.to_s] = value
        end
      end

      def fields(*attrs)
        attrs.each do |symbol_or_array|
          field(symbol_or_array)
        end
      end

      def find(id)
        new Request.get("#{strapi_content_type_name}/#{id}").data
      end

      def find_by(query_hash)
        hash = strapi_filter_query(query_hash)[0]
        raise NotFoundError unless hash

        new(hash)
      end

      def all
        Request.get(strapi_content_type_name).data.map do |result|
          new result
        end
      end

      def where(query_hash)
        strapi_filter_query(query_hash).map(&method(:new))
      end

      def strapi_filter_query(query_hash)
        Request.get("#{strapi_content_type_name}?#{query_hash.to_query}").data
      end
    end
  end
end
