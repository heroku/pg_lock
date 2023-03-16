# A Log of Changes!

## Main - unreleased

## 1.0.0

- Fixed: Lock is now unlocked when an exception is raised in a log https://github.com/heroku/pg_lock/pull/17
- Changed: Removed mis-spelling of "aquired" https://github.com/heroku/pg_lock/pull/17

## 0.3.0

- Fix method spelling (https://github.com/heroku/pg_lock/pull/16)

## 0.2.1

- Fix regression where a block that returned a `false` would cause the `lock!` method to incorrectly raise an error (https://github.com/heroku/pg_lock/pull/15)

## 0.2.0

- Return the result evaluated inside the block (https://github.com/heroku/pg_lock/pull/10)

## [0.1.2] - 2017-12-06

- Support Rails 5 and newer PG versions [#5]

## [0.1.1] - 2015-10-07

- Allow setting default connection with constant.

## [0.1.0] - 2015-10-06

- First version.
