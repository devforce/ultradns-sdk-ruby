#!/usr/bin/env ruby

require 'ultradns'
require 'pp'

@user = ENV['ULTRA_USER']
@pw = ENV['ULTRA_PW']
zone_name = ARGV[0]

if @user.nil? || @pw.nil? || zone_name.nil?
  puts "ULTRA_USER=<account name> ULTRA_PW=<account password> #{$0} <zone>"
  exit 1
end

client = Ultradns::Client.new(@user, @pw)

resp = client.zone(zone_name).metadata

puts "\nZone (#{zone_name}) Properties: "
pp resp['properties']


