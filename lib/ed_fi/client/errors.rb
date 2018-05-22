require 'crapi'

class EdFi::Client < Crapi::Client
  class Error < ::StandardError
  end

  class ArgumentError < Error
  end

  class UnableToAuthenticateError < Error
  end
end
