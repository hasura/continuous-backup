#!/bin/bash

if [[ -z ${PGDATA+x} ]]; then
  PGDATA=/var/lib/postgresql/data
fi

if [[ -z $SCHEDULE ]]; then
  # daily 4 times
  SCHEDULE='0 */6 * * *'
fi

echo "Hasura Backup System: Configuring WAL-E"

echo "$WALE_S3_PREFIX"        > /etc/wal-e.d/env/WALE_S3_PREFIX
echo "$AWS_ACCESS_KEY_ID"     > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_REGION"            > /etc/wal-e.d/env/AWS_REGION

chown -R postgres:postgres /etc/wal-e.d/*

echo "Hasura Backup System: Setting up cron job"

cat <<EOF >> /etc/cron.d/pg_basebackup
# Run pg base backups

${SCHEDULE} postgres envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push $PGDATA >> /var/log/cron.log 2>&1
EOF

cat /etc/cron.d/pg_basebackup

touch /var/log/cron.log
chown root:postgres /var/log/cron.log
chmod g+w /var/log/cron.log

cron

exec tail -F /var/log/cron.log
