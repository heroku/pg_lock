# PgLock

Uses [Postgres advisory locks](http://www.postgresql.org/docs/9.2/static/view-pg-locks.html) to enable you to syncronize actions across multiple threads, processes, and even machines.

## Installation

This gem requires Ruby 2.0+

Add this line to your application's Gemfile:

```ruby
gem 'pg_lock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_lock

## Usage

Create a `PgLock.new` instance and call the `lock` method to ensure exclusive execution of a block of code.

```ruby
PgLock.new(name: "all_your_base").lock do
  if open?
    API.log(circuit_breaker: true, enabled: true, service: service)
  else
    open!(error_count)
  end
end
```

Now no matter how many times this code is executed across any number of machines, one block of code will be allowed to execute at a time. A lock name is required.

## Timeout

By default, locked blocks will timeout after 60 seconds of execution, the lock will be released and any code executing will be terminated by a `Timeout::Error` will be raised. You can lower or raise this value by passing in a `ttl` (time to live) argument:

```ruby
begin
  PgLock.new(name: "all_your_base", ttl: 30).lock do
    # stuff
  end
rescue Timeout::Error
  puts "Took longer than 30 seconds to execute"
end
```

To disable the timeout pass in a falsey value:

```ruby
PgLock.new(name: "all_your_base", ttl: false).lock do
  # stuff
end
```

## Retry Attempts

By default if a lock cannot be aquired, `PgLock` will try 3 times with a 1 second delay between tries. You can configure this behavior using `attempts` and `attempt_interval` arguments:

```ruby
PgLock.new(name: "all_your_base", attempts: 10, attempt_interval: 5).lock do
  # stuff
end
```

To run once use `attempts: 1`.

## Raise Error on Failed Lock

You can optionally raise an error if a block cannot be executed in the given number of attempts by using the `lock!` method:

```ruby
begin
  PgLock.new(name: "all_your_base").lock! do
    # stuff
  end
rescue PgLock::UnableToLockError
  # do stuff
end
```

## Manual Lock

The `create` method will return the `PgLock` instance if a lock object was created, or `false` if no lock was aquired. You should manually `delete` a successfully created lock object:

```ruby
begin
  lock = PgLock.new(name: "all_your_base")
  lock.create
  # do stuff
ensure
  lock.delete
end
```

You can check on the status of a lock with the `aquired?` method:

```ruby
begin
  lock = PgLock.new(name: "all_your_base")
  lock.create
  if lock.aquired?
    # do stuff
  end
ensure
  lock.delete
end
```

## Logging

By default there is no logging, if you want you can provide a logging block:

```ruby
PgLock.new(name: "all_your_base", log: ->(data) { puts data.inspect }).lock do
  # stuff
end
```

One argument will be passed to the block, a hash of values. You can optionally define a default log for all instances:

```ruby
PgLock::DEFAULT_LOG = ->(data) { puts data.inspect }
```

Note: When you enable logging exceptions raised when deleting a lock will be swallowed. To re-raise you can use the exception in `data[:exception]`.

## Database Connection

This library defaults to use Active Record. If you want to use another library, or spin up a dedicated connection you can use the `connection` argument:

```ruby
my_connection = MyCustomConnectionObject.new
PgLock.new(name: "all_your_base", connection: my_connection).lock do
  # stuff
end
```

The object needs to respond to the `exec` method where the first argument is a query string, and the second is an array of bind arguments. For example to use with [sequel](https://github.com/jeremyevans/sequel) you could do something like this:


```ruby
connection = Module do
  def self.exec(sql, bind)
    DB.fetch(sql, bind)
  end
end

PgLock.new(name: "all_your_base", connection: my_connection).lock do
  # stuff
end
```

Where `DB` is to be your database connection.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pg_lock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknowledgements

Originally written by [@mikehale](https://github.com/mikehale)
