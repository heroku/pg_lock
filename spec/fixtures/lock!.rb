require_relative 'fixture_helper.rb'

puts "started"

PgLock.new(name: ENV.fetch("PG_LOCK_KEY")).lock! do
  puts "Running locked code on: #{ Process.pid }"
  sleep 3 # hold the lock for a bit
end

puts "done"
