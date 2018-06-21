require 'crapi'

## Note we're explicitly declaring "EdFi" as a module here so this file can be directly require'd
## from the base gemspec without issues.

## The EdFi module houses the {EdFi::Client EdFi::Client} in this gem, but should also house future
## EdFi tooling.
##
module EdFi
  class Client < Crapi::Client
    ## The canonical **ed_fi_client** gem version.
    ##
    ## This should only ever be updated *immediately* before a release; the commit that updates this
    ## value should be pushed **by** the `rake release` process.
    ##
    VERSION = '0.1.1'.freeze
  end
end
