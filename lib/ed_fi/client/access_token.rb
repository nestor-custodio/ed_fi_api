require 'crapi'

class EdFi::Client < Crapi::Client
  class AccessToken
    def initialize(access_token:, token_type:, issued_at: Time.current, expires_in:)
      @access_token = access_token.dup
      @token_type = token_type.dup
      @issued_at = issued_at.dup
      @expires_in = expires_in.dup
    end

    def token
      @access_token.dup
    end

    def expires_at
      return 1.second.ago if @access_token.blank?
      (@issued_at + @expires_in.seconds)
    end

    def valid?
      safety_window = 5.seconds
      Time.current <= (expires_at - safety_window)
    end
  end
end
