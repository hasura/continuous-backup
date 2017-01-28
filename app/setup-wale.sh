#!/bin/bash

# Assumption: the group is trusted to read secret information
umask u=rwx,g=rx,o=
#mkdir -p /etc/wal-e.d/env

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

# TODO: check if configuration already exists - then exit

chown -R postgres:postgres /etc/wal-e.d/*

echo "Hasura Backup System: Configuring Postgres for continous backup"

cat <<EOF >> /var/lib/postgresql/data/postgresql.conf

# Hasura wal-e configuration
wal_level = replica
archive_mode = on
archive_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p'
archive_timeout = 60

EOF

echo "Hasura Backup System: Scheduling WAL-E backups"
# echo "0 8 * * * postgres envdir /etc/wal-e.d/env wal-e backup-push $PGDATA" > /etc/cron.d/pg_base_backup

echo "Hasura Postgres: Done"
