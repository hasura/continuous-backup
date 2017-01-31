# TODO: remove python-all-dev? , libevent-dev?

FROM postgres:9.6.1
MAINTAINER anon@hasura.io

RUN apt-get update \
 && apt-get install -y \
            python-pip python3-pip python3-pkg-resources \
            postgresql-server-dev-$PG_MAJOR=$PG_VERSION \
            libpq-dev \
            daemontools libevent-dev python3-all-dev lzop pv \
 && pip install pgxnclient && pgxn install first_last_agg \
 && pip3 install wal-e[aws] \
 && pip uninstall -y pgxnclient \
 && apt-get purge -y --auto-remove python-pip python3-pip libpq-dev postgresql-server-dev-$PG_MAJOR=$PG_VERSION \
 && rm -rf ~/.cache/pip \
 && rm -rf /var/lib/apt/lists/*

COPY setup-wale.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/setup-wale.sh

RUN mkdir -p /etc/wal-e.d/env
RUN chown -R postgres:postgres /etc/wal-e.d

COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

COPY recover.sh /recover.sh
RUN chmod +x /recover.sh

COPY cronjob.sh /cronjob.sh
RUN chmod +x /cronjob.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["postgres"]
