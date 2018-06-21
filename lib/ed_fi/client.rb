require 'active_support/all'
require 'crapi'

require 'ed_fi/client/auth'
require 'ed_fi/client/errors'
require 'ed_fi/client/proxy'
require 'ed_fi/client/response'
require 'ed_fi/client/version'

module EdFi; end

## The main container defined by the **ed_fi_client** gem. Provides a connection mechanism, an
## authentication mechanism, simple CRUD methods ({#delete} / {#get} / {#patch} / {#post} / {#put}),
## and proxy generators.
##
## All other classes defined in this gem (including gem-specific `::Error` derivatives) are
## subclasses of {EdFi::Client EdFi::Client}.
##
class EdFi::Client < Crapi::Client
  ## The "profile" header content-type template.
  PROFILE_MIME_TYPE = 'application/vnd.ed-fi.%<resource>s.%<profile>s.%<access>s+json'.freeze

  ## @param base_uri [URI, String]
  ##   The base URI the client should use for determining the host to connect to, whether SSH is
  ##   applicable, and the path to the target API.
  ##
  ## @param opts [Hash]
  ##   Method options. All options not explicitly listed below are passed on to Crapi::Client.
  ##
  ## @option opts [String] :profile
  ##   The profile for which {EdFi::Client#read} and {EdFi::Client#write} will generate headers, if
  ##   any.
  ##
  ## @option opts [String] :client_id
  ##   The client id to use for authentication. This is AKA the "api key" / "username".
  ##
  ## @option opts [String] :client_secret
  ##   The client secret to use for authentication. This is AKA the "api secret" / "password".
  ##
  ##
  ## @raise [EdFi::Client::ArgumentError]
  ##
  def initialize(base_uri, opts = {})
    required_opts = %i[client_id client_secret]
    required_opts.each { |opt| raise ArgumentError, "missing keyword: #{opt}" unless opts.key? opt }

    super(base_uri, opts)
    self.profile = opts[:profile]

    ## Giving the EdFi::Client::Auth instance its own Crapi client lets us do fancy things with the
    ## API segmenting stuff ...
    ##
    auth_client = Crapi::Client.new(base_uri, opts)
    @auth = EdFi::Client::Auth.new(client: auth_client,
                                   client_id: opts[:client_id],
                                   client_secret: opts[:client_secret])
  end

  ## Sets the profile to use for {EdFi::Client#read} / {EdFi::Client#write} calls.
  ##
  ##
  ## @param profile [String, Symbol]
  ##   The profile for which {EdFi::Client#read} and {EdFi::Client#write} will generate headers.
  ##
  def profile=(profile)
    @profile = profile&.to_s&.downcase
  end

  ## rubocop:disable Naming/UncommunicativeMethodParamName

  ## Returns the header needed to {EdFi::Client#get} a resource with a profile.
  ##
  ##
  ## @param resource [String, Symbol]
  ##   The resource to be read.
  ##
  ## @param as [String, Symbol]
  ##   The profile to use. If one has already been set  via {EdFi::Client#initialize} or
  ##   {EdFi::Client#profile=}, this value is optional.
  ##
  ##
  ## @return [HashWithIndifferentAccess]
  ##
  def read(resource, as: nil)
    self.profile = as if as.present?
    mime_type = format(PROFILE_MIME_TYPE, resource: resource, profile: @profile, access: :readable)

    { 'Accept': mime_type }.with_indifferent_access
  end
  ## rubocop:enable Naming/UncommunicativeMethodParamName

  ## rubocop:disable Naming/UncommunicativeMethodParamName

  ## Returns the header needed to {EdFi::Client#delete} / {EdFi::Client#patch} / {EdFi::Client#post}
  ## / {EdFi::Client#put} a resource with a profile.
  ##
  ##
  ## @param resource [String, Symbol]
  ##   The resource to be written.
  ##
  ## @param as [String, Symbol]
  ##   The profile to use. If one has already been set  via {EdFi::Client#initialize} or
  ##   {EdFi::Client#profile=}, this value is optional.
  ##
  ##
  ## @return [HashWithIndifferentAccess]
  ##
  def write(resource, as: nil)
    self.profile = as if as.present?
    mime_type = format(PROFILE_MIME_TYPE, resource: resource, profile: @profile, access: :writable)

    { 'Content-Type': mime_type }.with_indifferent_access
  end
  ## rubocop:enable Naming/UncommunicativeMethodParamName

  ## CRUD methods ...

  ## CRUD method: DELETE
  ##
  ## *headers* and *query* are preprocessed for auth and case conversion, but all parameters are
  ## otherwise passed through to Crapi::Proxy#delete.
  ##
  def delete(path, headers: {}, query: {})
    (headers, query) = preprocess(headers, query)
    respond_with super(path, headers: headers, query: query)
  end

  ## CRUD method: GET
  ##
  ## *headers* and *query* are preprocessed for auth and case conversion, but all parameters are
  ## otherwise passed through to Crapi::Proxy#get.
  ##
  def get(path, headers: {}, query: {})
    (headers, query) = preprocess(headers, query)
    respond_with super(path, headers: headers, query: query)
  end

  ## CRUD method: PATCH
  ##
  ## *headers*, *query*, and *payload* are preprocessed for auth and case conversion, but all
  ## parameters are otherwise passed through to Crapi::Proxy#patch.
  ##
  def patch(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  ## CRUD method: POST
  ##
  ## *headers*, *query*, and *payload* are preprocessed for auth and case conversion, but all
  ## parameters are otherwise passed through to Crapi::Proxy#post.
  ##
  def post(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  ## CRUD method: PUT
  ##
  ## *headers*, *query*, and *payload* are preprocessed for auth and case conversion, but all
  ## parameters are otherwise passed through to Crapi::Proxy#put.
  ##
  def put(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  ## API segment proxies ...

  ## Convenience proxy generator for v2.0 API access, also addomg the school year you'd like to
  ## access, if given.
  ##
  ##
  ## @param period [Integer]
  ##   The school year to be accessed. (To access the v2.0 API for school year 2017-2018, call
  ##  `v2(2017)`.)
  ##
  ##
  ## @return [EdFi::Client::Proxy]
  ##
  def v2(period = nil)
    period = period.to_i

    @v2 = {} if @v2.nil?
    @v2[period] ||= begin
      path = '/api/v2.0'
      path += "/#{period}" if period.nonzero?
      EdFi::Client::Proxy.new(add: path, to: self)
    end
  end

  ##

  private

  ##

  ## Generates an auth header, with a valid Bearer token.
  ##
  ##
  ## @return [HashWithIndifferentAccess]
  ##
  def auth_header
    { 'Authorization': "Bearer #{@auth.token}" }.with_indifferent_access
  end

  ## Carries out preprocessing for headers, query data, and payload data, returning processed
  ## *copies* of the given values.
  ##
  ##
  ## @param headers [Hash]
  ##   The headers to preprocess. A copy of this value is returned with auth headers added, so long
  ##   as no key conflicts arise.
  ##
  ## @param query [Hash]
  ##   The querystring values to preprocess. Keys will be case-converted where necessary.
  ##
  ## @param payload [Hash]
  ##   The payload values to preprocess. Keys will be case-converted where necessary.
  ##
  ##
  ## @return [(Hash, Hash, Hash)]
  ##
  def preprocess(headers, query = nil, payload = nil)
    payload = payload.as_json if payload.is_a? EdFi::Client::Response

    headers = auth_header.merge(headers)
    query = query.deep_transform_keys { |key| key.to_s.camelize(:lower) } if query.is_a? Hash
    payload = payload.deep_transform_keys { |key| key.to_s.camelize(:lower) } if payload.is_a? Hash

    [headers, query, payload]
  end

  ## Returns an {EdFi::Client::Response EdFi::Client::Response} for the given API resonse value.
  ##
  ##
  ## @param response [Hash, Array]
  ##   The API response Hash/Array to convert to an {EdFi::Client::Response EdFi::Client::Response}.
  ##
  ##
  ## @return [EdFi::Client::Response]
  ##
  def respond_with(response)
    EdFi::Client::Response.new(response, client: self)
  end
end
