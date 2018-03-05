#!/bin/bash
[ -z "${SSHFS_TARGET}" ] && { echo "=> ERROR: SSHFS_TARGET cannot be empty ( format: USER@SERVER:PATH )" && exit 1; }
[ ! -f /backup.conf ] && { echo "=> ERROR: /backup.conf does not exist" && exit 1; }

#umount, ignore not mounted errors
umount /backup 2>/dev/null

#mount
sshfs -o reconnect,ServerAliveInterval=30,ServerAliveCountMax=3,StrictHostKeyChecking=no ${SSHFS_TARGET} /backup || { echo "=> ERROR: sshfs /backup failed" && exit 1; }

#check mount (does not work inside container...)
###mount | grep -q " /backup " || { echo "=> ERROR: /backup not mounted" && exit 1; }

#make backup from /host to /backup
DATE=$(date +%Y%m%d)
echo "=> Backup started at $DATE"

while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
  NAME=$(echo $LINE | cut -f1 -d' ')
  ARGS=$(echo $LINE | cut -f2- -d' ')
  if [[ ${NAME:0:1} != '#' ]] ; then
    echo "tar -C /host -czf /backup/${DATE}-${HOSTNAME}-${NAME}.tgz $ARGS"
    tar -C /host -czf /backup/${DATE}-${HOSTNAME}-${NAME}.tgz $ARGS
  fi
done < "/backup.conf"

#umount, ignore not mounted errors
umount /backup 2>/dev/null

echo "=> Backup done"
