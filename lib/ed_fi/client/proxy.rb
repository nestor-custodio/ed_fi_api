require 'crapi'

module EdFi; end
class EdFi::Client < Crapi::Client
  ## The Crapi::Proxy to {EdFi::Client}'s Crapi::Client.
  ##
  ## An {EdFi::Client::Proxy EdFi::Client::Proxy} calls {EdFi::Client::Response#client= #client=}
  ## on every CRUD-method-generated {EdFi::Client::Response EdFi::Client::Response}.
  ##
  class Proxy < Crapi::Proxy
    ## CRUD method: GET
    ##
    ## All parameters are passed directly through to Crapi::Proxy#get.
    ##
    def get(*args)
      response = super
      response.client = self

      response
    end

    ## CRUD method: DELETE
    ##
    ## All parameters are passed directly through to Crapi::Proxy#delete.
    ##
    def delete(*args)
      response = super
      response.client = self

      response
    end

    ## CRUD method: POST
    ##
    ## All parameters are passed directly through to Crapi::Proxy#post.
    ##
    def post(*args)
      response = super
      response.client = self

      response
    end

    ## CRUD method: PATCH
    ##
    ## All parameters are passed directly through to Crapi::Proxy#patch.
    ##
    def patch(*args)
      response = super
      response.client = self

      response
    end

    ## CRUD method: PUT
    ##
    ## All parameters are passed directly through to Crapi::Proxy#put.
    ##
    def put(*args)
      response = super
      response.client = self

      response
    end
  end
end
