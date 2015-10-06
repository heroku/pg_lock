require_relative 'fixture_helper.rb'

PgLock.new(name: testing_key("lock_once"), attempts: 1).lock do
  puts "Running locked code on: #{ Process.pid }"
  sleep 5 # hold the lock for a bit
end
