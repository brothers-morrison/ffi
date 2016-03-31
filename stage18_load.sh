#!/bin/sh

set -euf

/usr/local/pgsql/bin/postgres -D /tmp/testdb -p 1234 -c log_min_messages=PANIC&
PGPID=$!
trap "kill $PGPID" 0
createdb -h localhost -p 1234 jaseg
psql -f stage18.sql -h localhost -p 1234 jaseg
