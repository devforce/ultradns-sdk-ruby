#!/usr/bin/env ruby

require 'ultradns'

@user = ENV['ULTRA_USER']
@pw = ENV['ULTRA_PW']

if @user.nil? || @pw.nil?
  puts "ULTRA_USER=<account name> ULTRA_PW=<account password> #{$0}"
  exit 1
end

client = Ultradns::Client.new(@user, @pw)

result = client.status

puts "Result: #{result}"

