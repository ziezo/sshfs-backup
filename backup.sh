#!/bin/bash

function log {
  echo "`date +'%Y-%m-%d %H:%M:%S'` $1"
}

[ -z "${SSHFS_TARGET}" ] && { log "ERROR: SSHFS_TARGET cannot be empty ( format: USER@SERVER:PATH )" && exit 1; }
[ ! -f /backup.conf ] && { log "ERROR: /backup.conf does not exist" && exit 1; }

#umount, ignore not mounted errors
umount /backup 2>/dev/null

#mount
sshfs -o reconnect,ServerAliveInterval=30,ServerAliveCountMax=3,StrictHostKeyChecking=no ${SSHFS_TARGET} /backup || { echo "=> ERROR: sshfs /backup failed" && exit 1; }

#check mount (does not work inside container...)
###mount | grep -q " /backup " || { echo "=> ERROR: /backup not mounted" && exit 1; }

#make backup from /host to /backup
DATE=$(date +%Y%m%d)
log "=== Backup started"

while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
  NAME=$(echo $LINE | cut -f1 -d' ')
  ARGS=$(echo $LINE | cut -f2- -d' ')
  if [[ ${NAME:0:1} != '#' && "$ARGS" != "" ]] ; then
    log "tar -C /host -czf /backup/${DATE}-${HOSTNAME}-${NAME}.tgz $ARGS"
    tar -C /host -czf /backup/${DATE}-${HOSTNAME}-${NAME}.tgz $ARGS
  fi
done < "/backup.conf"

#umount, ignore not mounted errors
umount /backup 2>/dev/null

log "=== Backup completed"
