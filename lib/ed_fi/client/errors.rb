require 'crapi'

class EdFi::Client < Crapi::Client
  ## The base Error class for all {EdFi::Client}-related issues.
  ##
  class Error < ::StandardError
  end

  ## An error relating to missing, invalid, or incompatible method arguments.
  ##
  class ArgumentError < Error
  end

  ## An error relating to a bad request for an authorization *code* or access *token*. This is most
  ## likely due to a connectivity issue, a bad base URI in the given client, or invalid credentials.
  ##
  class UnableToAuthenticateError < Error
  end
end
