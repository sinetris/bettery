# Bettery

[![Build Status](https://travis-ci.org/sinetris/bettery.svg?branch=master)](https://travis-ci.org/sinetris/bettery)

Ruby toolkit for working with the [Betterplace API][betterplace_api].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bettery', github: 'sinetris/bettery'
```

And then execute:

    $ bundle

## Usage

```ruby
projects = Bettery.projects
projects.fields => #<Set: {:total_entries, :offset, :total_pages, :current_page, :per_page, :data}>
projects.total_entries #=> 11149
projects.data.first.title #=> "Mit der DKMS im Kampf gegen Blutkrebs!"
```

## Contributing

1. Fork it ( https://github.com/sinetris/bettery/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[betterplace_api]: https://github.com/betterplace/betterplace_apidocs
