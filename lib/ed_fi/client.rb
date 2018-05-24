require 'active_support/all'
require 'crapi'

require 'ed_fi/client/auth'
require 'ed_fi/client/errors'
require 'ed_fi/client/proxy'
require 'ed_fi/client/response'
require 'ed_fi/client/version'

class EdFi::Client < Crapi::Client
  PROFILE_MIME_TYPE = 'application/vnd.ed-fi.%<resource>s.%<profile>s.%<access>s+json'.freeze

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

  def profile=(profile)
    @profile = profile&.to_s&.downcase
  end

  ## rubocop:disable Naming/UncommunicativeMethodParamName
  def read(resource, as: nil)
    self.profile = as if as.present?
    mime_type = format(PROFILE_MIME_TYPE, resource: resource, profile: @profile, access: :readable)

    { 'Accept': mime_type }.with_indifferent_access
  end
  ## rubocop:enable Naming/UncommunicativeMethodParamName

  ## rubocop:disable Naming/UncommunicativeMethodParamName
  def write(resource, as: nil)
    self.profile = as if as.present?
    mime_type = format(PROFILE_MIME_TYPE, resource: resource, profile: @profile, access: :writable)

    { 'Content-Type': mime_type }.with_indifferent_access
  end
  ## rubocop:enable Naming/UncommunicativeMethodParamName

  ## CRUD methods ...

  def delete(path, headers: {}, query: {})
    (headers, query) = preprocess(headers, query)
    respond_with super(path, headers: headers, query: query)
  end

  def get(path, headers: {}, query: {})
    (headers, query) = preprocess(headers, query)
    respond_with super(path, headers: headers, query: query)
  end

  def patch(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  def post(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  def put(path, headers: {}, query: {}, payload: {})
    (headers, query, payload) = preprocess(headers, query, payload)
    respond_with super(path, headers: headers, query: query, payload: payload)
  end

  ## API segment proxies ...

  def v2(period)
    @v2 ||= EdFi::Client::Proxy.new(add: "/api/v2.0/#{period}", to: self)
  end

  ##

  private

  ##

  def auth_header
    { 'Authorization': "Bearer #{@auth.token}" }.with_indifferent_access
  end

  def preprocess(headers, query = nil, payload = nil)
    headers = auth_header.merge(headers)
    query = query.deep_transform_keys { |key| key.to_s.camelize(:lower) } if query.is_a? Hash
    payload = payload.deep_transform_keys { |key| key.to_s.camelize(:lower) } if payload.is_a? Hash

    [headers, query, payload]
  end

  def respond_with(response)
    EdFi::Client::Response.new(response, client: self)
  end
end
