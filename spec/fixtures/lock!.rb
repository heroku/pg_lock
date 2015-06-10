require_relative 'fixture_helper.rb'

STDERR.puts "started"

PgLock.new(name: ENV.fetch("PG_LOCK_KEY")).lock! do
  STDERR.puts "Running locked code on: #{ Process.pid }"
  sleep 3 # hold the lock for a bit
end

