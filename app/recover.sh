#!/bin/bash

echo "Hasura Recovery System: Configuring WAL-E"

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

chown -R postgres:postgres /etc/wal-e.d/*

# backup postgresql.conf
cp $PGDATA/postgresql.conf /postgresql.conf
cp $PGDATA/pg_hba.conf /pg_hba.conf
cp $PGDATA/pg_ident.conf /pg_ident.conf

echo "Hasura Recovery System: Obliterating current data directory ${PGDATA}/*"
gosu postgres rm -r ${PGDATA}/*

echo "Hasura Recovery System: Fetching latest base backup"
gosu postgres envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-fetch $PGDATA LATEST

echo "Hasura Recovery System: Restoring backups"
cat <<EOF >> $PGDATA/recovery.conf
restore_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-fetch "%f" "%p"'
EOF

# restore the postgresql.conf
mv /postgresql.conf $PGDATA/postgresql.conf
mv /pg_hba.conf $PGDATA/pg_hba.conf
mv /pg_ident.conf $PGDATA/pg_ident.conf

chown -R postgres:postgres $PGDATA/*

echo "Hasura Recovery System: Starting Postgres server"
/docker-entrypoint.sh postgres
