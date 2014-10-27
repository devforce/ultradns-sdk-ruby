
# UltraDNS SDK

This SDK implements a subset of the UltraDNS functionality. It does not attempt to implement a client for all available UltraDNS REST API functionality.
Adding additional functionality should be relatively straightforward, and any contributions from the UltraDNS community would be greatly appreciated.


[![Build Status](https://travis-ci.org/ultradns/ultradns-sdk-ruby.svg?branch=master)](https://travis-ci.org/ultradns/ultradns-sdk-ruby)

## Installation

Add this line to your application's Gemfile:

    gem 'ultradns-sdk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ultradns-sdk

## Usage


* Right now only basic records are supported and RD (Resource Distribution) Pools.

### Sample Usage

```ruby

require 'ultradns-sdk'

client = Ultradns::Client.new("username", "secret password")

# create a test zone
client.create_primary_zone("myaccount", "somezone.biz")
# create an A record
client.zone("somezone.biz").rrset('A', 'www').create(60, ['192.168.1.1'])

# list the resource record sets (rrsets)
client.zone("somezone.biz").rrsets

# list the A resource record sets
client.zone("somezone.biz").rrsets('A')

```

## Future

* Directional Pools
* Mail Forwarding
* Web Forwarding



## Contributing

1. Fork it ( https://github.com/[my-github-username]/ultradns-sdk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
