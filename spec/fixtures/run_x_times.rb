require_relative 'fixture_helper.rb'

ENV["COUNT"].to_i.times do |i|
  PgLock.new(name: "all_your_base_#{i}", attempts: 1).lock do
    puts "Running locked code on: #{ Process.pid }"
    sleep 2 # hold the lock for a bit
  end
end
