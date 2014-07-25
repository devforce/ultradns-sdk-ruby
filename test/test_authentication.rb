# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

require_relative 'test_helper'

class TestAuthentication < Minitest::Unit::TestCase
  include UltraDNSCredentials

  TEST_ACCOUNT = ENV['ULTRA_ACCOUNT'] || "jdamick"

  def setup
    setup_credentials
  end

  def test_auth
    client = Ultradns::Client.new(@user, @pw)

    pp client.account(TEST_ACCOUNT).zones

    pp client.accounts

    result = client.status
    assert result['message'] != nil
  end

  def test_auth_failure
    client = Ultradns::Client.new(@user, @pw)
    client.instance_eval { @auth[:access_token] = 'xx' }
    response = client.status
    assert response['message'] != nil
  end
end
