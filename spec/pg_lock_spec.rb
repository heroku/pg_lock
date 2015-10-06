require 'spec_helper'

describe PgLock do
  it 'has a version number' do
    expect(PgLock::VERSION).not_to be nil
  end

  it "lock! raises an error" do
    key = testing_key("lock! raises an error")
    out = ""
    PgLock.new(name: key).lock do
      out = run("env PG_LOCK_KEY='#{ key }' bundle exec ruby #{ PgLockSpawn.fixture_path("lock!.rb") }")
    end
    expect_output_has_message(out: out, count: 1, msg: "PgLock::UnableToLockError")
  end

  it "attempts" do
    max_attempts = rand(2..9)
    key          = testing_key("attempts")
    # x attempts
    # Note mocking out `lock` returns nil` which forces the lock aquire to fail
    fails_to_lock = PgLock.new(name: key, attempts: max_attempts)
    expect(fails_to_lock.send(:locket)).to receive(:lock).exactly(max_attempts).times
    fails_to_lock.lock {}

    # 0 attempts should try once
    fails_to_lock = PgLock.new(name: key, attempts: 0)
    expect(fails_to_lock.send(:locket)).to receive(:lock).exactly(1).times
    fails_to_lock.lock {}
  end

  it "ttl" do
    key  = testing_key("ttl")
    time = rand(2..4)
    expect {
      PgLock.new(name: key, ttl: time).lock do
        sleep time + 0.1
      end
    }.to raise_error(Timeout::Error)
  end

  it "log" do
    key = testing_key("log")
    log = ->(data) {}
    expect(log).to receive(:call).with(hash_including(at: :create, pg_lock: true))
    expect(log).to receive(:call).with(hash_including(at: :delete, pg_lock: true))
    PgLock.new(name: key, log: log).lock {}
  end

  it "default log" do
    key = testing_key("default log")
    begin
      original = defined?(PgLock::DEFAULT_LOG) ? PgLock::DEFAULT_LOG : nil

      PgLock::DEFAULT_LOG = ->(data) {}
      expect(PgLock::DEFAULT_LOG).to receive(:call).with(hash_including(at: :create, pg_lock: true))
      expect(PgLock::DEFAULT_LOG).to receive(:call).with(hash_including(at: :delete, pg_lock: true))
      PgLock.new(name: key).lock {}
    ensure
      PgLock::DEFAULT_LOG = original
    end
  end

  it "only runs X times" do
    begin
      count = rand(2..9)
      log   = PgLockSpawn.new_log_file
      10.times.map do
        Process.spawn("env COUNT=#{count} bundle exec ruby #{PgLockSpawn.fixture_path("run_x_times.rb")} >> #{log}")
      end.each do |pid|
        Process.wait(pid)
      end
      expect_log_has_count(log: log, count: count)
    ensure
      FileUtils.remove_entry_secure log
    end
  end

  it "only runs once" do
    begin
      log = PgLockSpawn.new_log_file
      5.times.map do
        Process.spawn("bundle exec ruby #{PgLockSpawn.fixture_path("lock_once.rb")} >> #{log}")
      end.each do |pid|
        Process.wait(pid)
      end
      expect_log_has_count(log: log, count: 1)
    ensure
      FileUtils.remove_entry_secure log
    end
  end


  it 'does not raise an error' do
    PgLock.new(name: testing_key("foo")) do
      puts 1
    end
    expect(true).to eq(true)
  end
end
