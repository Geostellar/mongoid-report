# Mongoid Report

Library for easy building aggregation report using mongodb aggregation
framework.

[![Gem Version](https://badge.fury.io/rb/mongoid-report.svg)](http://badge.fury.io/rb/mongoid-report)

[![Build Status](https://secure.travis-ci.org/oivoodoo/mongoid-report.png?branch=master)](https://travis-ci.org/oivoodoo/mongoid-report)

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/oivoodoo/mongoid-report)

### Example

```ruby
  class Model
    include Mongoid::Document

    field :field1, type: Integer, default: 0
    field :field2, type: Integer, default: 0

    field :day,    type: Date
  end

  class Report1
    include Mongoid::Report

    report 'example' do
      attach_to Model do
        group_by :day
        column :field1, collection: Model
      end
    end
  end
```

```ruby
  example = Report4.new
  scope = example.aggregate_for(Model)
  scope = scope.query('match' => { 'field1' => 1 })
  result = scope.all

  result.is_a?(Array) => true
  result[0].is_a?(Hash) => true

  example = Report5.new
  scope = example.aggregate_for('summary-report')
  result = scope.all
```

## Installation

Add this line to your application's Gemfile:

    gem 'mongoid-report'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-report

## Contributors

  [@oivoodoo](http://github.com/oivoodoo) and  [@baltazore](http://github.com/baltazore)

## Contributing

1. Fork it ( http://github.com/oivoodoo/mongoid-report/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
