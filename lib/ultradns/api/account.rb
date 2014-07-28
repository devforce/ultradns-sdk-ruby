# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require_relative 'client_accessor'

class Ultradns::Api::Account < Ultradns::Api::ClientAccessor

  attr_reader :account_name

  def initialize(client, account_name)
    super(client)
    @account_name = account_name
  end


  # List zones for this account
  #
  #
  # === Optional Parameters
  #
  # * +:q+ - The search parameters, in a hash.  Valid keys are:
  #          name - substring match of the zone name
  #          zone_type - one of :
  #              PRIMARY
  #              SECONDARY
  #              ALIAS
  # * +:sort+ - The sort column used to order the list. Valid values for the sort field are:
  #             NAME
  #             ACCOUNT_NAME
  #             RECORD_COUNT
  #             ZONE_TYPE
  # * +:reverse+ - Whether the list is ascending(false) or descending(true).  Defaults to true
  # * +:offset+ - The position in the list for the first returned element(0 based)
  # * +:limit+ - The maximum number of zones to be returned.
  #
  # === Examples
  #
  #     client.account('myaccount').zones
  #     client.account('myaccount').zones(q: {name: 'foo', zone_type: 'PRIMARY'}, sort: 'NAME', reverse: true, offset:10, limit:50)
  def zones(options={})
    client.with_auth_retry {|c| c.get("/accounts/#{@account_name}/zones", request_options(options)) }
  end

  # List users for this account
  def users()
    client.with_auth_retry {|c| c.get "/accounts/#{@account_name}/users", request_options }
  end

end
