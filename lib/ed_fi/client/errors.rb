class EdFi::Client
  class Error < ::StandardError
  end

  class ArgumentError < Error
  end

  class UnableToAuthenticateError < Error
  end
end
