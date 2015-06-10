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

def testing_key(base)
  [base, ENV["TRAVIS_BUILD_ID"] , ENV["TRAVIS_JOB_ID"] ].compact.join(":")
end
