# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require 'httparty'
require 'logger'

require_relative 'api/authentication'
require_relative 'api/account'
require_relative 'api/client_accessor'
require_relative 'api/rrset'
require_relative 'api/zone'

class Ultradns::Client
  include HTTParty
  include Ultradns::Api::Authentication

  disable_rails_query_string_format
  default_timeout 30
  open_timeout 10
  read_timeout 10
  headers({'Accept' => 'application/json', 'Content-Type' => 'application/json'})
  format :json # force the format to json

  # base uri for the service
  base_uri 'https://restapi.ultradns.com/v1'

  debug_output $stdout if ENV['DEBUG']


  # Initialize an Ultra REST API client
  #
  # === Required Parameters
  #
  # * +username+ - The user name
  # * +password+ - The user's password
  #
  # === Optional Parameters
  #
  # * +:use_http+ - Use http instead of https.  Defaults to false, set to true only in test environments.  Will not work in production.
  # * +:host+ - host and port of the remote server.  Defaults to restapi.ultradns.com.
  #
  # === Examples
  #
  #     c = RestClient.new("myUname", "myPwd")
  #     c = RestClient.new("myUname", "myPwd", host: 'restapi-useast1b01-01.ct.ultradns.net:8080')
  def initialize(username, password, options = {})
    @logger ||= ::Logger.new($stdout)

    auth(username, password)

    @options = {}
    # override or ignored if nil
    @options[:base_uri] = HTTParty.normalize_base_uri(options[:host]) if options[:host]

    logger.debug "Initializing UltraDNS Client using #{@options.inspect}"
  end



  # Get version of REST API server
  #
  # === Examples
  #
  #     c.version
  def version
    with_auth_retry {|c| c.get '/version', request_options }
  end


  # Get status of REST API server
  #
  # === Examples
  #
  #     c.status
  def status
    with_auth_retry {|c| c.get '/status', request_options }
  end


  # Access Account Level Resources for the given account_name
  #
  # === Required Parameters
  #
  # * +account_name+ - One of the user's accounts.  The user must have read access for zones in that account.
  #
  def account(account_name)
    Ultradns::Api::Account.new(self, account_name)
  end

  # Get account details for user
  #
  # === Examples
  #
  #     c.accounts
  def accounts
    with_auth_retry {|c| c.get '/accounts', request_options }
  end


  # === Required Parameters
  #
  # * +zone_name+ - The name of the zone.
  #
  def zone(zone_name)
    Ultradns::Api::Zone.new(self, zone_name)
  end


  # Create a primary zone
  #
  # === Required Parameters
  #
  # * +account_name+ - The account that the zone will be created under.  The user must have write access for zones in that account.
  # * +zone_name+ - The name of the zone.  The trailing . is optional.  The zone name must not be in use by anyone.
  #
  # === Examples
  #
  #     c.create_primary_zone('my_account', 'zone.invalid.')
  def create_primary_zone(account_name, zone_name)
    zone_properties = {:name => zone_name, :accountName => account_name, :type => 'PRIMARY'}
    primary_zone_info = {:forceImport => true, :createType => 'NEW'}

    zone_data = {:properties => zone_properties, :primaryCreateInfo => primary_zone_info}

    with_auth_retry {|c| c.post '/zones', request_options({:body => zone_data.to_json}) }
  end



  protected
  #########
  def request_options(params = {})
    add_auth_header!(params)
    @options.merge(build_params(params))
  end


  def logger
    @logger
  end

  def build_params(args)
    params = {}
    if args[:q]
      q = args[:q]
      q_str = ''
      q.each { |k, v| q_str += "#{k}:#{v} " }
      if q_str.length > 0
        params[:q] = q_str
      end
      args.delete :q
    end
    params.update(args)
    params
  end

end
