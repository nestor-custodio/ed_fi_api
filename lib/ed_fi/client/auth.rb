require 'crapi'
require 'json'

require 'ed_fi/client/access_token'
require 'ed_fi/client/errors'

module EdFi; end
class EdFi::Client < Crapi::Client
  ## The {EdFi::Client::Auth EdFi::Client::Auth} represents a complete authentication *mechanism*
  ## that makes the necessary calls for authorization codes and access tokens, keeps track of any
  ## token generated, and re-requests new tokens as necessary based on the existing token's
  ## lifecycle.
  ##
  ##
  class Auth
    ## The URI to request an authorization code.
    AUTHORIZATION_CODE_URI = '/oauth/authorize'.freeze

    ## The MIME content type to use for authorization code requests.
    AUTHORIZATION_CODE_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze

    ## The URI to request an access token.
    ACCESS_TOKEN_URI = '/oauth/token'.freeze

    ## The MIME content type to use for access token requests.
    ACCESS_TOKEN_CONTENT_TYPE = 'application/json'.freeze

    ## @param client [Crapi::Client]
    ##   The client to use for making auth calls.
    ##
    ## @param client_id [String]
    ##   The client id to use for authentication. This is AKA the "api key" / "username".
    ##
    ## @param client_secret [String]
    ##   The client secret to use for authentication. This is AKA the "api secret" / "password".
    ##
    def initialize(client:, client_id:, client_secret:)
      @client = client
      @client_id = client_id
      @client_secret = client_secret

      @access_token = nil
    end

    ## Gives an access token string that is guaranteed to be valid for *at least* 5 seconds.
    ##
    ## Note a new token is requested and returned if the existing token is no longer valid.
    ##
    ##
    ## @return [String]
    ##
    def token
      @access_token = new_access_token unless @access_token&.valid?
      @access_token.token
    end

    ##

    private

    ##

    ## Requests and yields a new authorization *code".
    ##
    ##
    ## @raise [EdFi::Client::UnableToAuthenticateError]
    ##
    ## @return [String]
    ##
    def new_authorization_code
      auth = @client.post(
        AUTHORIZATION_CODE_URI,
        payload: { Client_id: @client_id, Response_type: 'code' },
        headers: { 'Content-Type': AUTHORIZATION_CODE_CONTENT_TYPE }
      )
      raise EdFi::Client::UnableToAuthenticateError, 'Failed to fetch authorization code.' unless auth&.key? :code

      auth[:code]
    end

    ## Requests and yields a new access *token*.
    ##
    ##
    ## @raise [EdFi::Client::UnableToAuthenticateError]
    ##
    ## @return [EdFi::Client::AccessToken]
    ##
    def new_access_token
      auth = @client.post(
        ACCESS_TOKEN_URI,
        payload: { Client_id: @client_id, Client_secret: @client_secret,
                   Code: new_authorization_code, Grant_type: 'authorization_code' },
        headers: { 'Content-Type': ACCESS_TOKEN_CONTENT_TYPE }
      )
      raise EdFi::Client::UnableToAuthenticateError, 'Failed to fetch access token.' unless auth&.key? :access_token

      EdFi::Client::AccessToken.new(auth)
    end
  end
end
