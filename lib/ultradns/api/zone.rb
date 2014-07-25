# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require_relative 'client_accessor'

class Ultradns::Api::Zone < Ultradns::Api::ClientAccessor

  attr_reader :zone_name

  def initialize(client, zone_name)
    super(client)
    @zone_name = zone_name
  end

  # Get zone metadata
  #
  # === Examples
  #
  #     c.zone('foo.invalid.').metadata
  def metadata
    client.with_auth_retry {|c| c.get "/zones/#{@zone_name}", request_options }
  end

  # Create a zone
  #
  # === Required Parameters
  #
  # * +account_name+ - The account that the zone will be created under.  The user must have write access for zones in that account.
  #
  # === Optional Parameters
  #
  # * +type+ - The type of zone to be created, one of three possible values: PRIMARY,  SECONDARY, or ALIAS.
  #
  # See documentation section: Primary Zone DTO or Secondary Zone DTO for further options.
  # === Examples
  #
  #     c.create('my_account')
  def create(account_name, options = {})
    zone_properties = {name: @zone_name, accountName: account_name, type: 'PRIMARY'}

    primary_zone_info = {}
    if options[:properties][:type] == 'PRIMARY' || options[:properties][:type] == nil
      primary_zone_info = {forceImport: true, createType: 'NEW'}
    end

    zone_data = {properties: zone_properties,
                 primaryCreateInfo: primary_zone_info}.merge(options)

    with_auth_retry {|c| c.post '/zones', request_options({body: zone_data.to_json}) }
  end

  # Delete a zone
  #
  # === Examples
  #
  #     c.zone('foo.invalid.').delete
  def delete
    client.with_auth_retry {|c| c.delete "/zones/#{@zone_name}", request_options }
  end



  # Returns the list of RRSets in the specified zone of the (optional) specified type.
  #
  # === Optional Parameters
  #
  # * +rtype+ - The type of the RRSets.  This can be numeric (1) or
  #             if a well-known name is defined for the type (A), you can use it instead.
  #
  # === Optional Parameters
  #
  # * +:q+ - The search parameters, in a hash.  Valid keys are:
  #          ttl - must match the TTL for the rrset
  #          owner - substring match of the owner name
  #          value - substring match of the first BIND field value
  # * +:sort+ - The sort column used to order the list. Valid values for the sort field are:
  #             OWNER
  #             TTL
  #             TYPE
  # * +:reverse+ - Whether the list is ascending(false) or descending(true).  Defaults to true
  # * +:offset+ - The position in the list for the first returned element(0 based)
  # * +:limit+ - The maximum number of zones to be returned.
  #
  # === Examples
  #
  #     c.zone('foo.invalid.').rrsets() # all types returned
  #     c.zone('foo.invalid.').rrsets('A')
  #     c.zone('foo.invalid.').rrsets('TXT', q: {value: 'cheese', ttl:300}, offset:5, limit:10)
  def rrsets(rtype = nil, options={})
    rrsets_path = "/zones/#{@zone_name}/rrsets"
    rrsets_path += "/#{rtype}" if rtype != nil

    client.with_auth_retry {|c| c.get(rrsets_path, request_options(options)) }
  end


  # === Required Parameters
  # * +rtype+ - The type of the RRSet.This can be numeric (1) or if a well-known name
  #              is defined for the type (A), you can use it instead.
  # * +owner_name+ - The owner name for the RRSet.
  #                   If no trailing dot is supplied, the owner_name is assumed to be relative (foo).
  #                   If a trailing dot is supplied, the owner name is assumed to be absolute (foo.zonename.com.)
  #
  # === Examples
  #
  #     c.rrset('A', 'foo')
  def rrset(rtype, owner_name)
    Ultradns::Api::Rrset.new(self, rtype, owner_name)
  end

  # Creates a new RRSet in the specified zone.
  #
  # === Required Parameters
  #
  # * +zone_name+ - The zone that contains the RRSet.The trailing dot is optional.
  # * +rtype+ - The type of the RRSet.This can be numeric (1) or
  #             if a well-known name is defined for the type (A), you can use it instead.
  # * +owner_name+ - The owner name for the RRSet.
  #                  If no trailing dot is supplied, the owner_name is assumed to be relative (foo).
  #                  If a trailing dot is supplied, the owner name is assumed to be absolute (foo.zonename.com.)
  # * +ttl+ - The updated TTL value for the RRSet.
  # * +rdata+ - The updated BIND data for the RRSet as a string.
  #             If there is a single resource record in the RRSet, you can pass in the single string or an array with a single element.
  #             If there are multiple resource records in this RRSet, pass in a list of strings.
  #
  # === Examples
  #
  #     c.zone('zone.invalid.').create_rrset('A', 'foo', 300, '1.2.3.4')
  def create_rrset(rtype, owner_name, ttl, rdata)
    rrset(rtype, owner_name).create(ttl, rdata)
  end


end
