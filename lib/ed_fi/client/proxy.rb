require 'crapi'

class EdFi::Client < Crapi::Client
  class Proxy < Crapi::Proxy
    def get(*args)
      response = super
      response.client = self

      response
    end

    def delete(*args)
      response = super
      response.client = self

      response
    end

    def post(*args)
      response = super
      response.client = self

      response
    end

    def patch(*args)
      response = super
      response.client = self

      response
    end

    def put(*args)
      response = super
      response.client = self

      response
    end
  end
end
