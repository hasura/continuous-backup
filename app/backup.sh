#!/bin/bash

if [[ -z ${PGDATA+x} ]]; then
  PGDATA=/var/lib/postgresql/data
fi

echo "Hasura Backup System: Configuring WAL-E"

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

chown -R postgres:postgres /etc/wal-e.d/*

echo "Hasura Backup System: Pushing base backup"

envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push $PGDATA

if [[ $? -ne 0 ]]; then
  echo "Hasura Backup System: Error pushing base backup"
  exit 1
fi

echo "Hasura Backup System: Done"
