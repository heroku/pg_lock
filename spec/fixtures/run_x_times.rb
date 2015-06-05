require_relative 'fixture_helper.rb'

ENV["COUNT"].to_i.times do |i|
  break if @already_run
  name = "all_your_base_#{i}_#{ ENV["TRAVIS_BUILD_ID"] }:#{ ENV["TRAVIS_JOB_ID"] }"
  PgLock.new(name: name, attempts: 1).lock do
    @already_run = true
    puts "Running locked code on: #{ Process.pid }, key: #{ name }"
    sleep 3 # hold the lock for a bit
  end
end
