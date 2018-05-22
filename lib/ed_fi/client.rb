require 'active_support/all'
require 'crapi'

require 'ed_fi/client/auth'
require 'ed_fi/client/errors'
require 'ed_fi/client/version'

class EdFi::Client
  PROFILE_CONTENT_TYPE = 'application/vnd.ed-fi.%<resource>s.%<profile>s.%<access>s+json'.freeze

  def initialize(base_uri:, client_id:, client_secret:, profile: nil, insecure: nil)
    @client = Crapi::Client.new(base_uri, insecure: insecure)
    @profile = profile

    auth_client = @client.new_proxy
    @auth = EdFi::Client::Auth.new(client: auth_client,
                                   client_id: client_id,
                                   client_secret: client_secret)
  end

  ## CRUD methods ...

  def delete(path, headers: {}, query: {})
    headers = auth_header.merge(headers)
    @client.delete(path, headers: headers, query: query)
  end

  def get(path, headers: {}, query: {})
    headers = auth_header.merge(headers)
    @client.get(path, headers: headers, query: query)
  end

  def patch(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    @client.patch(path, headers: headers, query: query, payload: payload)
  end

  def post(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    @client.post(path, headers: headers, query: query, payload: payload)
  end

  def put(path, headers: {}, query: {}, payload: {})
    headers = auth_header.merge(headers)
    @client.put(path, headers: headers, query: query, payload: payload)
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
               raise EdFi::Client::ArgumentError, "Invalid `access` value: #{access.inspect}"
             end

    content_type = format(PROFILE_CONTENT_TYPE,
                          resource: resource.downcase,
                          profile: @profile.downcase,
                          access: access)

    { 'Accept': content_type, 'Content-Type': content_type }
  end
end
