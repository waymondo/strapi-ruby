# Strapi

[Strapi](https://strapi.io) is an Open source Node.js Headless CMS to easily build customizable
APIs. It’s great for quickly building your data layer alongside a UI to manage it.

Say you (like me) like to quickly build sites and applications in Ruby and/or/on Rails. The goal of
the Strapi gem is to make it just as easy to define Ruby classes that represent and interact with
your Strapi content types as it is to define them within Strapi itself.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'strapi', github: 'waymondo/strapi-ruby'
```

And then execute:

    $ bundle install

This gem has only been tested with Strapi v4. It may work with previous versions of Strapi, but they
remain untested.

## Usage

### Configuration

You will first need to set an `ENV` variable for `STRAPI_HOST_URL` and `STRAPI_API_TOKEN` (the
  latter is only required if accessing content types requires authentication). This can be done with
  [`dotenv`](https://github.com/bkeepers/dotenv/), in an initializer, or some other mechanism.

If using `dotev`, your `.env` file would contain:

```
STRAPI_HOST_URL=http://localhost:1337
STRAPI_API_TOKEN=asdf1234qwer5678
```

#### Defining Content Type Classes

In Ruby, define some content type classes, i.e.:

``` ruby
class Farm < Strapi::ContentType
  field :name
  field :cows, content_type: 'Cow'
  field :photo, content_type: 'Strapi::Media'
end
```

``` ruby
class Cow < Strapi::ContentType
  field :name
  field :farm, content_type: 'Farm'
end
```

Using the `field` class method will define getter and setter methods for the class objects. If you
supply a class name to the `content_type` option, it will transform it to an instance of that class
when using the getter method. This works for both one-to-one and one-to-many relations:

``` ruby
cow.name # => "Hershey"
cow.farm # => #<Farm>
farm.name # => "McDonald’s"
farm.cows # => [#<Cow>, #<Cow>]
```

[`Strapi::Media`](https://github.com/waymondo/strapi-ruby/blob/main/lib/strapi/media.rb) is an
included content type class to represent photos, videos, and files. Feel free to extend this class
if you would like to add additional functionality or granularity.

``` ruby
farm.photo # => #<Strapi::Media>
farm.photo.url # => "http://localhost:1337/uploads/farm-1.jpg"
```

By default, `Strapi::ContentType` will infer it’s API plural id from the demodulized, dasherized,
pluralized name of the ruby class. For example, it would assume a class of `FarmWorker` would have a
Strapi plural ID of `farm-workers`. If you would like to customize this, you can set it in the class
definition:

``` ruby
class FarmWorker
  plural_id 'farmers'
end
```

### Fetching Entries

`Strapi::ContentType` provides some predictable methods for retrieving entries from your Strapi API:

``` ruby
Cow.all # => [#<Cow>, #<Cow>, #<Cow>]
cow = Cow.find(1)
cow.id # => 1
```

Both `.all` and `.find` accept a hash of options that map to Strapi’s allowed [API
parameters](https://docs.strapi.io/developer-docs/latest/developer-resources/database-apis-reference/rest-api.html). No
parameter options are included by default, so if you want to eagerly load related content types for
example, you’ll need to specify that with the `populate` option:

``` ruby
cows = Cow.all(populate: "*")
cows.first.farm.name # => "McDonald’s"
farm = Farm.find(1, populate: ['cows'])
farm.cows.first.name # => "Hershey"
```

The class method `.where` also exists, which is the same implementation as `.all`, except a hash of
API parameters is required.

### CRUD

Coming Soon

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and the created tag, and push the `.gem`
file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/waymondo/strapi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
