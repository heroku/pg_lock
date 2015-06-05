$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pg_lock'

require 'active_record'

begin
  ActiveRecord::Base.establish_connection(
    adapter:  'postgresql',
    database: 'pg_lock_test'
  )
  ActiveRecord::Base.connection.raw_connection.exec("select 1")
rescue ActiveRecord::NoDatabaseError => e
  msg = "\nCreate a database to continue `$ createdb pg_lock_test` \n" + e.message
  raise e, msg
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
    log = Pathname.new("tmp/logs/pg_lock#{rand(1...2000)}_#{Time.now.to_f}.log")
    FileUtils.mkdir_p(log.dirname)
    FileUtils.touch(log)
    log
  end
end
