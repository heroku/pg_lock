require_relative 'fixture_helper.rb'

puts "started lock!"

sleep_for = (ENV["SLEEP_FOR"] || 3).to_i

PgLock.new(name: ENV.fetch("PG_LOCK_KEY")).lock! do
  puts "Running locked code on: #{ Process.pid }"
  sleep sleep_for # hold the lock for a bit
end

puts "done with lock!"
