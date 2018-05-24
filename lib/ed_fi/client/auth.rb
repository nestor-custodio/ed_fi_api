require 'crapi'
require 'json'

require 'ed_fi/client/access_token'
require 'ed_fi/client/errors'

class EdFi::Client < Crapi::Client
  class Auth
    AUTHORIZATION_CODE_URI = '/oauth/authorize'.freeze
    AUTHORIZATION_CODE_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze

    ACCESS_TOKEN_URI = '/oauth/token'.freeze
    ACCESS_TOKEN_CONTENT_TYPE = 'application/json'.freeze

    def initialize(client:, client_id:, client_secret:)
      @client = client
      @client_id = client_id
      @client_secret = client_secret

      @access_token = nil
    end

    def token
      @access_token = new_access_token unless @access_token&.valid?
      @access_token.token
    end

    ##

    private

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
