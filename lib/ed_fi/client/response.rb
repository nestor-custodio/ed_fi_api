require 'crapi'

class EdFi::Client < Crapi::Client
  class Response
    def initialize(response, client: nil)
      @client = client

      case response
      when Hash
        @response = response.to_a.map do |tuple|
          (key, value) = tuple.dup
          key = key.to_s.underscore.to_sym
          value = EdFi::Client::Response.new(value, client: @client) if value.is_a?(Hash) || value.is_a?(Array)

          [key, value]
        end.to_h

      when Array
        @response = response.dup.map do |i|
          i = EdFi::Client::Response.new(i, client: @client) if i.is_a?(Hash) || i.is_a?(Array)
          i
        end

      else
        raise EdFi::Client::ArgumentError, %(Unexpected "response" type: #{response.class})

      end
    end

    def client=(client)
      @client = client

      case @response
      when Hash
        @response.values.each { |i| i.client = client if i.is_a? EdFi::Client::Response }

      when Array
        @response.each { |i| i.client = client if i.is_a? EdFi::Client::Response }

      end
    end

    def to_json
      @response.to_json
    end

    ## rubocop:disable Style/MethodMissing
    def method_missing(name, *args, &block)
      if @response.is_a? Hash
        ## Allow for acceess to response values via dot notation.
        return @response[name] if @response.key? name

        ## Allow for simple access to referenced resources.
        if @client.present?
          reference = @response["#{name}_reference".to_sym].link.href rescue nil
          return @client.get(reference) if reference.present?
        end
      end

      ## All other unaccounted-for method calls should be delegated to the response Hash/Array.
      @response.send(name, *args, &block)
    end
    ## rubocop:enable Style/MethodMissing

    def respond_to_missing?(name, include_private = false)
      ( \
        ( \
          (@response.is_a? Hash) \
          && \
          ( \
            @response.key?(name) \
            || \
            @response.key?("#{name}_reference".to_sym) \
          ) \
        ) \
        || \
        @response.respond_to?(name, include_private) \
      )
    end
  end
end
