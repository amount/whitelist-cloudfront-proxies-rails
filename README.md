# Cloudfront::Rails

This Gem is a shameless copy of [cloudflare-rails](https://github.com/modosc/cloudflare-rails), but for [CloudFront](https://aws.amazon.com/cloudfront/)

## Installation

__This gem now supports Rails 5, for Rails 4, please use version ~> 0.1.0__

Add this line to your application's Gemfile:

```ruby
group :production do
  gem 'whitelist_cloudfront_proxies-rails', avant_repo: 'whitelist-cloudfront-proxies-rails', tag: 'v0.2.0' # or 0.1.X for Rails 4
end
```

And then execute:

    $ bundle

## Usage

The code gets the list of proxies from `https://ip-ranges.amazonaws.com/ip-ranges.json`, updates the cache accordingly. This then whitelists these proxy ranges so that `request.ip` and `request.remote_ip` does not return these proxies.

For configuration

```ruby
config.whitelist_cloudfront_proxies.expires_in = 1.hour # Cache expiry for the ips
config.whitelist_cloudfront_proxies.timeout = 2.seconds # Timeout for the http access
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avantcredit/whitelist-cloudfront-proxies-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

