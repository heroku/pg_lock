require 'tempfile'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pg_lock'

require 'fixtures/fixture_helper'

require "open3"

def expect_log_has_count(log:, count:, msg: "Running locked code")
  contents = File.read(log)
  actual   = contents.scan(msg).count
  expect(actual).to eq(count), "Expected #{msg.inspect} to occur #{count} times but was #{ actual.inspect } in:\n#{ contents.inspect }"
end


def fixtures(name)
  Pathname.new(File.expand_path("../fixtures", __FILE__)).join(name)
end

require 'open3'

def run(cmd)
  out = ""
  Open3.popen3("#{cmd} 2>&1") do |stdin, stdout, stderr, wait_thr|
    out = stdout.read
  end
  out
end

def expect_output_has_message(out: , count: , msg: "Running locked code")
  actual   = out.scan(msg).count
  expect(actual).to eq(count), "Expected #{msg.inspect} to occur #{count} times but was #{ actual.inspect } in:\n#{ out.inspect }"
end



class PgLockSpawn

  attr_accessor :path, :frequency, :reap_duration, :config, :log, :ram, :pid, :puma_workers

  def initialize(options = {})
    @path           = options[:path] || self.class.fixture_path("lock_once.rb")
    @log            = options[:log]  || self.class.new_log_file
  end

  def wait_for_output(regex = %r{booted}, timeout = 30)
    Timeout::timeout(timeout) do
      until log.read.match regex
        sleep 1
      end
    end
    sleep 1
    self
  rescue Timeout::Error
    puts "Timeout waiting for #{regex.inspect} in \n#{log.read}"
    false
  end

  def wait_till_Dead
    Process.wait(pid)
  end

  def cleanup
    shutdown
    FileUtils.remove_entry_secure log
  end

  def shutdown
    if pid
      Process.kill('TERM', pid)
      Process.wait(pid)
    end
  rescue Errno::ESRCH
  end

  def spawn
    @pid = Process.spawn("bundle exec ruby #{path} > #{log}")
    self
  end

  def self.fixture_path(name = nil)
    path = Pathname.new(File.expand_path("../fixtures", __FILE__))
    path = path.join(name) if name
    path
  end

  def self.new_log_file
    Pathname.new(Tempfile.new(["pg_lock", ".log"]))
  end
end
