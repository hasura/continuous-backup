#!/bin/bash

if [[ -z ${PGDATA+x} ]]; then
  PGDATA=/var/lib/postgresql/data
fi

echo "Hasura Recovery System: Configuring WAL-E"

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

chown -R postgres:postgres /etc/wal-e.d/*

echo "Hasura Recovery System: Stopping Postgres server"
gosu postgres pg_ctl stop || echo "Already stopped"

echo "Hasura Recovery System: Removing current data directory"
gosu postgres rm -r ${PGDATA}

echo "Hasura Recovery System: Fetching latest base backup"
gosu postgres envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-fetch $PGDATA LATEST

echo "Hasura Recovery System: Restoring backups"
cat <<EOF >> $PGDATA/recovery.conf
restore_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-fetch "%f" "%p"'
EOF

chown -R postgres:postgres $PGDATA/*

echo "Hasura Recovery System: Starting Postgres server"

