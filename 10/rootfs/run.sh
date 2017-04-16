#!/bin/bash
set -e

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

DAEMON=mysqld_safe
EXEC=$(which $DAEMON)
ARGS="--defaults-file=/opt/bitnami/mariadb/conf/my.cnf"

# configure command line flags for replication
if [[ -n $MARIADB_REPLICATION_MODE ]]; then
  ARGS+=" --server-id=$RANDOM --binlog-format=ROW --log-bin=mysql-bin"
  case $MARIADB_REPLICATION_MODE in
    master)
      ARGS+=" --innodb_flush_log_at_trx_commit=1 --sync-binlog=1"
      ;;
    slave)
      ARGS+=" --relay-log=mysql-relay-bin --log-slave-updates=1 --read-only=1 --replicate-do-db=$MARIADB_DATABASE"
      ;;
  esac
fi

info "Starting ${DAEMON}..."
exec ${EXEC} ${ARGS}
