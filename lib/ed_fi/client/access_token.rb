require 'crapi'

module EdFi; end
class EdFi::Client < Crapi::Client
  ## The {EdFi::Client::AccessToken EdFi::Client::AccessToken} represents an access token, as
  ## returned by "/oauth/token" calls.
  ##
  class AccessToken
    ## An {EdFi::Client::AccessToken EdFi::Client::AccessToken} can be initiialized with the
    ## "/oauth/token" response Hash. If given, an additional "issued_at" Time value helps to more
    ## accurately calculate the token's expiration Time.
    ##
    ##
    ## @param access_token [String]
    ##   The actual token value to use as the Bearer token in subsequent requests.
    ##
    ## @param token_type [String]
    ##   The token type (e.g. "bearer").
    ##
    ## @param issued_at [Time]
    ##   An optional value denoting the Time at which the token was issued.
    ##   If unset, defaults to `Time.current`.
    ##
    ## @param expires_in [Numeric]
    ##   The token's lifetime, in seconds.
    ##
    def initialize(access_token:, token_type:, issued_at: Time.current, expires_in:)
      @access_token = access_token.dup
      @token_type = token_type.dup
      @issued_at = issued_at.dup
      @expires_in = expires_in.dup
    end

    ## Gives a copy of the token *value*.
    ##
    ##
    ## @return [String]
    ##
    def token
      @access_token.dup
    end

    ## Gives the token's *calculated* expiration Time.
    ##
    ##
    ## @return [Time]
    ##
    def expires_at
      return 1.second.ago if @access_token.blank?
      (@issued_at + @expires_in.seconds)
    end

    ## Denotes whether the token is still "valid", per its (calculated) expiration timesstamp. Note
    ## that a 5-second window is allotted for the request using the token to complete.
    ##
    ##
    ## @return [true,false]
    ##
    def valid?
      safety_window = 5.seconds
      Time.current <= (expires_at - safety_window)
    end
  end
end
