require 'crapi'

## Note we're explicitly declaring "EdFi" as a module here so this file can be directly require'd
## from the base gemspec without issues.
##
module EdFi
  class Client < Crapi::Client
    VERSION = '0.1.0'.freeze
  end
end
