# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require_relative 'test_helper'

class TestClientApi < Minitest::Unit::TestCase
  include UltraDNSCredentials

  TEST_ZONE = "ultra-rest-test.ultradnstest"
  TEST_ACCOUNT = ENV['ULTRA_ACCOUNT'] || "jdamick"

  def setup
    setup_credentials
  end

  def test_basic_client_apis
    VCR.use_cassette('test_basic_client_apis') do
      client = Ultradns::Client.new(@user, @pw)

      result = client.status
      assert result['message'] != nil

      result = client.version
      assert result['version'] != nil
    end
  end

  def test_tasks_list
    VCR.use_cassette('test_tasks_list') do
      client = Ultradns::Client.new(@user, @pw)
      resp = client.tasks(q: {code: 'PENDING'})
      assert_equal 70002, resp.first['errorCode']
    end
  end

  def test_account_related_apis
    VCR.use_cassette('test_account_related_apis') do
      client = Ultradns::Client.new(@user, @pw)

      resp = client.accounts
      assert resp['resultInfo'] != nil
      assert resp['accounts'] != nil

      resp = client.account(TEST_ACCOUNT).zones
      assert resp['zones'] != nil

      resp = client.account(TEST_ACCOUNT).users
      assert resp['users'].size > 0
      assert resp['resultInfo']['totalCount'] != nil
    end
  end

  def test_zone_apis
    VCR.use_cassette('test_zone_apis') do
      client = Ultradns::Client.new(@user, @pw)

      resp = client.zone('nexgen.neustar.biz').metadata
      assert resp['properties'] != nil

      resp = client.zone('nexgen.neustarr.biz').metadata
      assert resp.first['errorCode'] != nil
      assert_equal 404, resp.code
    end
  end

  def test_zone_rrsets_apis
    VCR.use_cassette('test_zone_rrsets_apis') do
      begin
        client = Ultradns::Client.new(@user, @pw)

        # create a test zone
        resp = client.create_primary_zone(TEST_ACCOUNT, TEST_ZONE)
        assert_equal 201, resp.code

        resp = client.zone(TEST_ZONE).metadata
        assert resp['properties'] != nil
        assert resp['registrarInfo'] != nil

        resp = client.zone(TEST_ZONE).rrset('A', 'something').create(60, ['192.168.1.1'])
        assert_equal 201, resp.code

        resp = client.zone(TEST_ZONE).rrsets
        assert_equal TEST_ZONE, resp["zoneName"]
        assert_equal 3, resp["resultInfo"]["totalCount"]

        resp = client.zone(TEST_ZONE).rrsets('A')
        assert_equal TEST_ZONE, resp["zoneName"]
        assert_equal 1, resp["resultInfo"]["totalCount"]
        assert_equal "A (1)", resp["rrSets"].first["rrtype"] # why both in 1 field?
        assert_equal 60, resp["rrSets"].first["ttl"]
        assert_equal "192.168.1.1", resp["rrSets"].first["rdata"].first


        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE).list
        assert_equal TEST_ZONE, resp["zoneName"]
        assert resp["rrSets"] != nil

        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE).update(30)
        assert 200, resp.code # docs say 201, but it appears to give back 200..

        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE).list
        assert_equal 30, resp["rrSets"].first["ttl"]

        # create a simple Traffic Controller Pool
        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE)
          .profile({
                    '@context' => 'http://schemas.ultradns.com/RDPool.jsonschema',
                    description: "Pooled Records Test",
                    order: "RANDOM"
                    })

        assert_equal "Successful", resp['message']

        # add another ip
        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE).update(60, ['192.168.3.3'])


        resp = client.zone(TEST_ZONE).rrset('A', 'something.' + TEST_ZONE).list
        assert_equal "RANDOM", resp['rrSets'].first['profile']['order']
        assert_equal 2, resp['rrSets'].first['rdata'].size

      ensure
        client.zone(TEST_ZONE).delete
      end
    end
  end

end
