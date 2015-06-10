require_relative 'fixture_helper.rb'

ENV["COUNT"].to_i.times do |i|
  break if @already_run
  name = testing_key("run_x_times_#{i}")
  PgLock.new(name: name, attempts: 1).lock do
    @already_run = true
    puts "Running locked code on: #{ Process.pid }, key: #{ name }"
    sleep 3 # hold the lock for a bit
  end
end
