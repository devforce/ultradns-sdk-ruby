# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

module Ultradns::Api::Authentication


  # Try a request and if there is an authentication failure, retry after
  # refreshing the tokens.
  #
  # yields to the block with the class so that HTTParty class methods can be used.
  # Example:  with_auth_retry {|c| c.get '/' }
  def with_auth_retry(&block)
    retries = 3
    response = nil
    while retries > 0
      response = yield(self.class)
      if auth_failure?(response)
        refresh
        retries = retries - 1
        logger.info "authentication failure, retrying..." if retries > 0
      else
        retries = 0
      end
    end
    response
  end

  def auth_failure?(response)
    error_code = response.parsed_response["errorCode"] rescue nil
    (response.code == 400 || response.code == 401) && error_code == 60001
  end

  def add_auth_header!(params)
    refresh if params[:force_refresh]
    (params[:headers] ||= {})['Authorization'] = "Bearer #{access_token}"
    params
  end

  def auth(username, password, base_uri)
    @auth = {}
    @auth[:requested_at] = Time.now.to_i
    response = self.class.post('/authorization/token',
      body: {
        grant_type: 'password',
        username: username,
        password: password
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      base_uri: base_uri
    )

    body = response.parsed_response

    logger.debug "Auth Response: #{response.inspect}"
    raise "Authentication Error: #{response.body}" unless response.code == 200

    # temp
    @auth[:username] = username
    @auth[:password] = password
    @auth[:base_url] = base_uri

    @auth[:access_token] = body['accessToken']
    @auth[:refresh_token] = body['refreshToken']
    @auth[:expires_in] = body['expiresIn']
  end

  def no_expiry?
    # no expires provided yet - TBD
    @auth[:expires_in] == nil || @auth[:expires_in] == ''
  end

  def refresh?
    (@auth[:requested_at] + @auth[:expires_in]) >= Time.now.to_i
  end

  def refresh
    # expires not available, then reauth
    return auth(@auth[:username], @auth[:password], @auth[:base_url]) if no_expiry?

    # not expired yet.
    return unless refresh?

    requested_at = Time.now.to_i
    response = @client.post('/authorization/token') do |request|
      request.params[:grant_type] = 'refresh_token'
      request.params[:refreshToken] = @auth[:refresh_token]
    end

    logger.debug "Auth Refresh Response: #{response.inspect}"
    raise "Token Refresh Error: #{response.body}" unless response.code == 200

    body = response.parsed_response

    @auth.clear # reset everything
    @auth[:requested_at] = requested_at
    @auth[:access_token] = body['accessToken']
    @auth[:refresh_token] = body['refreshToken']
    @auth[:expires_in] = body['expiresIn']
  end

  def access_token
    @auth[:access_token]
  end
end
