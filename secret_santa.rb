#!/usr/bin/env ruby

require 'yaml/store'

class Giftee
  attr_reader :name, :forbidden_gifters

  def initialize(name, *forbidden_gifters)
    @name = name
    @forbidden_gifters = (forbidden_gifters << name).compact
  end

  def random_gifter_name(candidates)
    (candidates - forbidden_gifters).sample
  end
end

class Community
  attr_reader :people

  def initialize(people = [])
    @people = people
  end

  class << self
    def parse(data)
      # TODO: Extract this into a module in case the community class tends to grow.
      people = data.map { |person_or_couple|
        if person_or_couple.include?(',')
          couple = person_or_couple.split(',').map(&:strip)
          [
            # Making sure we include the previous santa into forbidden gifters.
            Giftee.new(*couple, previously_assigned_santas.fetch(couple.first, nil)),
            Giftee.new(*couple.reverse, previously_assigned_santas.fetch(couple.last, nil))
          ]
        else
          person = person_or_couple.strip
          Giftee.new(person, previously_assigned_santas.fetch(person, nil))
        end
      }.flatten

      new(people)
    end

    def store
      @store ||= YAML::Store.new('store.yml')
    end

  private

    def previously_assigned_santas
      store.transaction { store[:santas] } || {}
    end
  end

  def secret_santa_for(person)
    { person.name => person.random_gifter_name(names) }
  end

  def secret_santas
    # Tha #reduce call transforms an array of hashes into a single hash.
    santas = @people.map { |person| secret_santa_for(person) }.reduce({}, :merge)
    self.class.store.transaction { self.class.store[:santas] = santas }
    santas
  end

  def names
    @people.map(&:name)
  end
end

if ARGV.any?
  begin
    Community.parse(File.readlines(ARGV[0])).secret_santas.each do |person_with_santa|
      puts "#{person_with_santa.first} — #{person_with_santa.last}"
    end
  rescue Exception => error
    puts error.message
  end
else
  puts 'Please pass in the name of the file with the list of participants.'
end
