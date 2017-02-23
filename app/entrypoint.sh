#!/bin/bash

set -e

if [ "$1" = 'postgres' ]; then
  echo "arg1 is postgres"

  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "here 1"
    echo "$PGDATA/PG_VERSION does not exist"
  else
    echo "here 2"
    echo "$PGDATA/PG_VERSION exist, ensuring wal-e is set to run"
    . /docker-entrypoint-initdb.d/setup-wale.sh
  fi

  echo "here 22222"
  echo "Running command $1"
  . /docker-entrypoint.sh $1
fi

echo "here 33333"
if [ "$1" = 'backup' ]; then
  echo "here 4444"
  . /backup.sh
  exit 0
fi

if [ "$1" = 'recover' ]; then
  echo "here 5555"
  . /recover.sh
fi

echo "here always???"
echo "Executing: $@"
exec "$@"
