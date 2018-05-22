require 'crapi'

class EdFi::Client < Crapi::Client
  class AccessToken
    def initialize(access_token:, token_type:, issued_at: nil, expires_in:)
      @access_token = access_token.dup
      @token_type = token_type.dup
      @issued_at = (issued_at.dup || Time.current)
      @expires_in = expires_in.dup
    end

    def token
      @access_token.dup
    end

    def valid?
      safety_window = 5.seconds
      @access_token.present? && (Time.current <= (@issued_at + @expires_in.seconds - safety_window))
    end
  end
end
