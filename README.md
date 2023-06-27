# Merginator [![Gem Version](https://badge.fury.io/rb/merginator.svg)](https://badge.fury.io/rb/merginator) ![Build Status](https://github.com/RyanVerhey/merginator/actions/workflows/main.yml/badge.svg?branch=main)

Easily merge collections with a simple API!

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add Merginator

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install Merginator

## Usage

### Pattern Merge

Merge collections based on a defined pattern. Adding an optional total limits the number returned values.
```ruby
arrays = [
  Array.new(10, 'One'),
  Array.new(10, 'Two'),
  Array.new(10, 'Three'),
]
mergifier = Merginator.pattern_merge(4, 2, 1, total: 10)
mergifier.merge(arrays[0], arrays[1], arrays[2])
# => ['One', 'One', 'One', 'One', 'Two', 'Two', 'Three', 'One', 'One', 'One']
```

Need to merge the results of multiple queries, in Rails for example? Need to paginate your results, but you don't want to instantiate more results than you need? Merginator will tell you how many records you need to query:
```ruby
mergifier = Merginator.pattern_merge(4, 2, 1, total: 10)
counts = mergifier.counts # => [7, 2, 1]
mergifier.merge(Post.limit(counts[0]), Comment.limit(counts[1]), User.limit(counts[2]))
# => [#<Post>, #<Post>, #<Post>, #<Post>, #<Comment>, #<Comment>, #<User>, #<Post>, #<Post>, #<Post>]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RyanVerhey/merginator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/RyanVerhey/merginator/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Merginator project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/RyanVerhey/merginator/blob/main/CODE_OF_CONDUCT.md).
