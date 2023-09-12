# Fedora6::Client

The Fedora6::Client gem is for interaction with the Fedora6 Repository API, documented at https://wiki.lyrasis.org/display/FEDORA6x/REST+API+Specification

It was created by Thomas Wrobel <thomas.wrobel@bodliean.ox.ac.uk> in support of the integration between ORA (https://ora.ox.ac.uk) and the ORA Digital Preservation Service.

A comapnion class that uses this gem for preserving objects within the API is ORA::DPS, available on request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fedora6-client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fedora6-client

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bodleian/fedora6-client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
