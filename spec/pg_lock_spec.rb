require 'spec_helper'

describe PgLock do
  it 'has a version number' do
    expect(PgLock::VERSION).not_to be nil
  end

  it "only runs X times" do
    begin
      count = rand(1..9)
      log = PgLockSpawn.new_log_file
      10.times.map do
        Process.spawn("env COUNT=#{count} bundle exec ruby #{PgLockSpawn.fixture_path("run_x_times.rb")} >> #{log}")
      end.each do |pid|
        Process.wait(pid)
      end
      expect(File.read(log).each_line.count {|x| x.include?("Running locked code") }).to eq(count)
    ensure
      FileUtils.remove_entry_secure log
    end
  end

  it "only runs once" do
    begin
      log = PgLockSpawn.new_log_file
      10.times.map do
        Process.spawn("bundle exec ruby #{PgLockSpawn.fixture_path("lock_once.rb")} >> #{log}")
      end.each do |pid|
        Process.wait(pid)
      end
      expect(File.read(log).each_line.count {|x| x.include?("Running locked code") }).to eq(1)
    ensure
      FileUtils.remove_entry_secure log
    end
  end


  it 'does not raise an error' do
    PgLock.new(name: "foo") do
      puts 1
    end
    expect(true).to eq(true)
  end
end
