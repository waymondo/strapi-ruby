module Strapi
  class Request
    class << self
      %i[get head delete trace post put patch].each do |method|
        define_method(method) do |*args|
          Response.new(Connection.instance.send(method, *args))
        end
      end
    end
  end
end
