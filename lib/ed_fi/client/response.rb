require 'crapi'

class EdFi::Client < Crapi::Client
  ## Represents an API response. {EdFi::Client::Response EdFi::Client::Response} instances
  ## initialized from a Hash also allow for reference chaining.
  ##
  class Response
    ## @param response [Hash, Array]
    ##   The value to encapsulate as an {EdFi::Client::Response EdFi::Client::Response}.
    ##
    ## @param client [Crapi::Client]
    ##   The client to use for request chaining.
    ##
    ##
    ## @raise [EdFi::Client::ArgumentError]
    ##
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

    ## Deep updates the associated Crapi::Client] for this and all descendant
    ## {EdFi::Client::Response EdFi::Client::Response} instances.
    ##
    def client=(client)
      @client = client

      case @response
      when Hash
        @response.values.each { |i| i.client = client if i.is_a? EdFi::Client::Response }

      when Array
        @response.each { |i| i.client = client if i.is_a? EdFi::Client::Response }

      end
    end

    ## @private
    ##
    def to_s
      @response.to_s
    end

    ## @private
    ##
    def inspect
      @response.inspect
    end

    ## rubocop:disable Security/Eval
    ##
    ## We're running `eval` on the `#to_s` of a built-in type, which is safe.
    ## Attempting to let `#as_json` run on its own results in a stack overflow.

    ## @private
    ##
    def as_json
      eval(to_s).as_json
    end
    ## rubocop:enable Security/Eval

    ## rubocop:disable Security/Eval
    ##
    ## We're running `eval` on the `#to_s` of a built-in type, which is safe.
    ## Attempting to let `#to_json` run on its own results in a stack overflow.

    ## @private
    ##
    def to_json
      eval(to_s).to_json
    end
    ## rubocop:enable Security/Eval

    ## rubocop:disable Style/MethodMissing, Metrics/BlockNesting

    ## @private
    ##
    def method_missing(name, *args, &block)
      ## Note references are cached.
      ## To force a refresh on an already-cached reference,
      ## the method should be called with a single `true` parameter.
      ## (i.e. `#school` vs `#school(true)`)

      if @response.is_a? Hash
        ## Allow for acceess to response values via dot notation.
        return @response[name] if @response.key? name

        ## Allow for simple access to referenced resources.
        if @client.present?
          @references ||= {}
          reference = @response["#{name}_reference".to_sym].link.href rescue nil

          if reference.present?
            @references.delete(reference) if args[0] == true
            return @references[reference] ||= @client.get(reference)
          end
        end
      end

      ## All other unaccounted-for method calls should be delegated to the response Hash/Array.
      @response.send(name, *args, &block)
    end
    ## rubocop:enable Style/MethodMissing, Metrics/BlockNesting

    ## @private
    ##
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
