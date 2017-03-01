#!/bin/bash

set -e

echo "Hasura Recovery System: Configuring WAL-E"

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

chown -R postgres:postgres /etc/wal-e.d/*

#if [[ ! -f $PGDATA/PG_VERSION ]]; then
#  echo "Cannot find an initialized Postgres directory."
#  echo "Make sure you intitialized a Postgres instance first and then run "
#  echo "the recovery"
#  exit 1;
#fi

# backup postgresql.conf
cp $PGDATA/postgresql.conf /postgresql.conf
cp $PGDATA/pg_hba.conf /pg_hba.conf
cp $PGDATA/pg_ident.conf /pg_ident.conf

#echo "sleeping..."
#sleep 300
#echo "slept for a long time..."

echo "Hasura Recovery System: Obliterating current data directory ${PGDATA}/*"
gosu postgres rm -r ${PGDATA}/*

echo "Hasura Recovery System: Fetching latest base backup"
gosu postgres envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-fetch $PGDATA LATEST

echo "Hasura Recovery System: Configuring restoration of backups"
cat <<EOF >> $PGDATA/recovery.conf
restore_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-fetch "%f" "%p"'
EOF

if [[ ! -z "$RECOVERY_TARGET_TIME" ]]; then
  echo "recovery_target_time = '${RECOVERY_TARGET_TIME}'" >> $PGDATA/recovery.conf
fi

# restore the postgresql.conf
mv /postgresql.conf $PGDATA/postgresql.conf
mv /pg_hba.conf $PGDATA/pg_hba.conf
mv /pg_ident.conf $PGDATA/pg_ident.conf

chown -R postgres:postgres $PGDATA/*
