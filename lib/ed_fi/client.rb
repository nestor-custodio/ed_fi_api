require 'active_support/all'
require 'crapi'

require 'ed_fi/client/auth'
require 'ed_fi/client/errors'
require 'ed_fi/client/response'
require 'ed_fi/client/version'

class EdFi::Client < Crapi::Client
  PROFILE_CONTENT_TYPE = 'application/vnd.ed-fi.%<resource>s.%<profile>s.%<access>s+json'.freeze

  def initialize(base_uri, opts = {})
    required_opts = %i[client_id client_secret]
    required_opts.each { |opt| raise ArgumentError, "missing keyword: #{opt}" unless opts.key? opt }

    super(base_uri, opts)
    @profile = opts[:profile]

    ## Giving the EdFi::Client::Auth instance its own Crapi client lets us do fancy things with the
    ## API segmenting stuff ...
    ##
    auth_client = Crapi::Client.new(base_uri, opts)
    @auth = EdFi::Client::Auth.new(client: auth_client,
                                   client_id: opts[:client_id],
                                   client_secret: opts[:client_secret])
  end

  ## CRUD methods ...

  def delete(path, headers: {}, query: {})
    headers = auth_header.merge(headers)
    response = super(path, headers: headers, query: query)

    EdFi::Client::Response.new(response)
  end

  def get(path, headers: {}, query: {})
    headers = auth_header.merge(headers)
    response = super(path, headers: headers, query: query)

    EdFi::Client::Response.new(response)
  end

  def patch(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    response = super(path, headers: headers, query: query, payload: payload)

    EdFi::Client::Response.new(response)
  end

  def post(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    response = super(path, headers: headers, query: query, payload: payload)

    EdFi::Client::Response.new(response)
  end

  def put(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    response = super(path, headers: headers, query: query, payload: payload)

    EdFi::Client::Response.new(response)
  end

  ## API segment proxies ...

   def v2(period)
     @v2 ||= EdFi::Client::Proxy.new(add: "/api/v2.0/#{period}", to: self)
   end

  ##

  private

  ##

  def auth_header
    { 'Authorization': "Bearer #{@auth.token}" }
  end

  def profile_header(resource, access)
    access = case access.to_sym
             when :read, :readable
               :readable
             when :write, :writable
               :writable
             else
               raise EdFi::Client::ArgumentError, %(Unexpected "access" value: #{access.inspect})
             end

    content_type = format(PROFILE_CONTENT_TYPE,
                          resource: resource.downcase,
                          profile: @profile.downcase,
                          access: access)

    { 'Accept': content_type, 'Content-Type': content_type }
  end
end
