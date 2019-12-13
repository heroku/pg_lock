class PgLock
  # Holds the logic to aquire a lock and parse if locking was successful
  class Locket
    TRUE_VALUES = [true, "t"].freeze

    attr_accessor :args, :connection
    def initialize(connection, lock_args)
      self.connection = connection
      self.args       = lock_args
    end

    def lock
      @lock = connection.exec("select pg_try_advisory_lock($1,$2)", args)
      return acquired?
    end

    def unlock
      connection.exec("select pg_advisory_unlock($1,$2)", args)
      @lock = false
    end

    def acquired?
      TRUE_VALUES.include?(@lock[0]["pg_try_advisory_lock"])
    rescue
      false
    end

    # Left the misspelled version of this method for backwards compatibility
    def aquired?
      acquired?
    end

    def active?
      active = connection.exec(<<-eos, args).getvalue(0,0)
        SELECT granted
        FROM pg_locks
        WHERE locktype = 'advisory' AND
         pid = pg_backend_pid() AND
         mode = 'ExclusiveLock' AND
         classid = $1 AND
         objid = $2
      eos

      TRUE_VALUES.include?(active)
    end
  end
end
