class PgLock
  # Holds the logic to aquire a lock and parse if locking was successful
  class Locket
    attr_accessor :args, :connection
    def initialize(connection, lock_args)
      self.connection = connection
      self.args  = lock_args
    end

    def lock
      @lock = connection.exec("select pg_try_advisory_lock($1,$2)", args)
      return aquired?
    end

    def unlock
      connection.exec("select pg_advisory_unlock($1,$2)", args)
      @lock = false
    end

    def aquired?
      @lock[0]["pg_try_advisory_lock"] == "t"
    rescue
      false
    end

    def active?
      connection.exec(<<-eos, lock_args).getvalue(0,0) == "t"
        SELECT granted
        FROM pg_locks
        WHERE locktype = 'advisory' AND
         pid = pg_backend_pid() AND
         mode = 'ExclusiveLock' AND
         classid = $1 AND
         objid = $2
      eos
    end
  end
end