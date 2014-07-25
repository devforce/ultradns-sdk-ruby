# Copyright 2000-2014 NeuStar, Inc. All rights reserved.
# NeuStar, the Neustar logo and related names and logos are registered
# trademarks, service marks or tradenames of NeuStar, Inc. All other
# product names, company names, marks, logos and symbols may be trademarks
# of their respective owners.

$:.unshift(File.expand_path(File.join('..', 'lib'), File.dirname(__FILE__)))

require 'pp'

require 'simplecov'
SimpleCov.start do
  use_merging true
  command_name "MiniTest #{Time.now}"
  add_group 'Service', 'service'
  add_group 'Library', 'lib'
  add_filter 'vendor' # Don't include vendored stuff
  add_filter 'test' # Don't include test stuff
end

require "minitest/autorun"
require "mocha/mini_test"
require 'ultradns'


module UltraDNSCredentials
  def setup_credentials
    @user = ENV['ULTRA_USER']
    @pw = ENV['ULTRA_PW']

    if @user == nil || @user == '' || @pw == nil || @pw == ''
      puts "\n\n------------------------------------------------------------"
      puts "ERROR - Please set ULTRA_USER & ULTRA_PW"
      puts "Example: \nULTRA_USER=me ULTRA_PW=blah bundle exec rake test\n"
      puts "------------------------------------------------------------\n\n"
      raise "Invalid UltraDNS account user name or password"
    end
  end
end
