# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require_relative 'client_accessor'

class Ultradns::Api::Rrset < Ultradns::Api::ClientAccessor

  attr_reader :rtype, :owner_name

  def initialize(zone, rtype, owner_name)
    super(zone)
    @zone_name = zone.zone_name
    @rtype = rtype
    @owner_name = owner_name
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
  #     c.zone('zone.invalid.').rrset('A', 'foo').create(300, '1.2.3.4')
  def create(ttl, rdata)
    rrset = {:ttl => ttl, :rdata => rdata}
    rrset[:rdata] = [rdata] unless rdata.kind_of? Array
    client.with_auth_retry {|c| c.post rrset_path, request_options({body: rrset.to_json}) }
  end


  # List all RRSets for this rtype and owner_name
  def list
    client.with_auth_retry {|c| c.get rrset_path, request_options }
  end

  # (Partially) Updates an existing RRSet for this rtype and owner_name in this zone
  #
  # === Required Parameters
  #
  # * +ttl+ - The updated TTL value for the RRSet.
  # * +rdata+ - The updated BIND data for the RRSet as a string.
  #             If there is a single resource record in the RRSet, you can pass in the single string or an array with a single element.
  #             If there are multiple resource records in this RRSet, pass in a list of strings.
  #                                                                                                                                                                                                                #
  # === Examples
  #
  #     c.update('zone.invalid.', "A", "foo", 100, ["10.20.30.40"])
  def update(ttl, rdata = nil)
    rrset = {}
    rrset[:ttl] = ttl if ttl != nil
    rrset[:rdata] = (rdata.kind_of?(Array) ? rdata : [rdata]) if rdata != nil

    client.with_auth_retry {|c| c.patch rrset_path, request_options({body: rrset.to_json}) }
  end

  # Updates (by replacing) an existing RRSet for this rtype and owner_name in this zone
  def replace()
  end


  # Delete an rrset
  #
  # === Required Parameters
  # * +zone_name+ - The zone containing the RRSet to be deleted.  The trailing dot is optional.
  # * +rtype+ - The type of the RRSet.This can be numeric (1) or if a well-known name
  #              is defined for the type (A), you can use it instead.
  # * +owner_name+ - The owner name for the RRSet.
  #                   If no trailing dot is supplied, the owner_name is assumed to be relative (foo).
  #                   If a trailing dot is supplied, the owner name is assumed to be absolute (foo.zonename.com.)
  #
  # === Examples
  #
  #     c.delete_rrset(first_zone_name, 'A', 'foo')
  def delete
    client.with_auth_retry {|c| c.delete rrset_path, request_options }
  end

  #
  # def profiles
  #   list()
  # end

  # Set the profile for the matching rrsets
  #
  def profile(options)
    client.with_auth_retry {|c| c.patch rrset_path, request_options({body: {profile: options}.to_json}) }
  end


  protected
  #########

  def rrset_path()
    "/zones/#{@zone_name}/rrsets/#{@rtype}/#{@owner_name}"
  end

end
