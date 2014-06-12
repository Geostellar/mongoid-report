require 'spec_helper'

describe Mongoid::Report do
  let(:klass) { Model }
  let(:yesterday) { Date.parse("19-12-2004") }
  let(:today) { Date.parse("20-12-2004") }
  let(:two_days_ago) { Date.parse("18-12-2004") }

  describe '.aggregate_for' do
    it 'aggregates fields by default group _id as well' do
      instance1 = klass.create!(day: today     , field1: 1)
      instance2 = klass.create!(day: today     , field1: 1)
      instance3 = klass.create!(day: yesterday , field1: 1)

      example = Report2.new
      rows = example.aggregate_for(klass)
      rows = rows.all

      expect(rows.size).to eq(3)
      expect(rows[0]['field1']).to eq(1)
      expect(rows[1]['field1']).to eq(1)
      expect(rows[2]['field1']).to eq(1)
    end

    it 'aggregates field by defined field of the mode' do
      klass.create!(day: today     , field1: 1)
      klass.create!(day: today     , field1: 1)
      klass.create!(day: yesterday , field1: 1)

      example = Report3.new

      rows = example.aggregate_for(klass)
      rows = rows.all

      expect(rows.size).to eq(2)
      expect(rows[0]['field1']).to eq(1)
      expect(rows[0]['day']).to eq(yesterday)
      expect(rows[1]['field1']).to eq(2)
      expect(rows[1]['day']).to eq(today)
    end

    it 'wraps group query by extra match queries' do
      klass.create(day: today        , field1: 1 , field2: 2)
      klass.create(day: today        , field1: 1 , field2: 2)
      klass.create(day: yesterday    , field1: 1 , field2: 2)
      klass.create(day: two_days_ago , field1: 1 , field2: 2)
      klass.create(day: today        , field1: 1 , field2: 3)

      example = Report3.new
      scope = example.aggregate_for(Model)
      scope = scope.query('$match' => { :day  => { '$gte' => yesterday.mongoize, '$lte' => today.mongoize } })
      scope = scope.query('$match' => { :field2 => 2 })
      scope = scope.yield
      scope = scope.query('$sort' => { day: -1 })

      rows  = scope.all

      expect(rows.size).to eq(2)
      expect(rows[0]['field1']).to eq(2)
      expect(rows[0]['day']).to eq(today)
      expect(rows[1]['field1']).to eq(1)
      expect(rows[1]['day']).to eq(yesterday)
    end

    it 'skips empty match in query' do
      klass.create(day: today , field1: 1 , field2: 2)

      example = Report3.new
      scope = example.aggregate_for(Model)
      scope = scope.query()
      scope = scope.query({})

      rows  = scope.all

      expect(rows.size).to eq(1)
      expect(rows[0]['field1']).to eq(1)
      expect(rows[0]['day']).to eq(today)
    end
  end

  class Report7
    include Mongoid::Report

    attach_to Model, as: 'example1' do
      group_by :day
      aggregation_field :field1
    end

    attach_to Model, as: 'example2' do
      group_by :day
      aggregation_field :field2
    end
  end

  describe '.aggregate' do
    it 'aggregates all defined groups in the report class' do
      klass.create(day: today        , field1: 1 , field2: 2)
      klass.create(day: today        , field1: 1 , field2: 2)
      klass.create(day: yesterday    , field1: 1 , field2: 2)
      klass.create(day: two_days_ago , field1: 1 , field2: 2)

      example = Report7.new
      scope = example.aggregate
      scope
        .query('$match' => { :day  => { '$gte' => yesterday.mongoize, '$lte' => today.mongoize } })
        .yield
        .query('$sort' => { day: -1 })
      scope = scope.all

      rows = scope['example1']
      expect(rows.size).to eq(2)
      expect(rows[0]['field1']).to eq(2)
      expect(rows[0]['day']).to eq(today)
      expect(rows[1]['field1']).to eq(1)
      expect(rows[1]['day']).to eq(yesterday)

      rows = scope['example2']
      expect(rows.size).to eq(2)
      expect(rows[0]['field2']).to eq(4)
      expect(rows[0]['day']).to eq(today)
      expect(rows[1]['field2']).to eq(2)
      expect(rows[1]['day']).to eq(yesterday)
    end
  end

end
