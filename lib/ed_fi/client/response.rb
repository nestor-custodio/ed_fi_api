require 'crapi'

class EdFi::Client < Crapi::Client
  class Response
    def initialize(source)
      case source
      when Hash
        @type = Hash
        @source = source.to_a.map do |tuple|
          (key, value) = tuple.dup
          key = key.to_s.underscore.to_sym
          value = EdFi::Client::Response.new(value) if value.is_a?(Hash) || value.is_a?(Array)

          [key, value]
        end.to_h

      when Array
        @type = Array
        @source = source.dup.map do |i|
          i = EdFi::Client::Response.new(i) if i.is_a?(Hash) || i.is_a?(Array)
          i
        end

      else
        raise EdFi::Client::ArgumentError, %(Unexpected "response" type: #{response.class})

      end
    end

    ## rubocop:disable Style/MethodMissing
    def method_missing(name, *args, &block)
      return @source[name] if (@type == Hash) && @source.key?(name)
      @source.send(name, *args, &block)
    end
    ## rubocop:enable Style/MethodMissing

    def respond_to_missing?(name, include_private = false)
      ((@type == Hash) && @source.key?(name)) || @source.respond_to?(name, include_private)
    end
  end
end
