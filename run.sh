#!/bin/bash
touch /backup.log
tail -F /backup.log &

[ -z "${SSHFS_TARGET}" ] && { echo "=> SSHFS_TARGET cannot be empty ( format: USER@SERVER:PATH )" && exit 1; }

if [ ! -f /root/.ssh/id_rsa ] ; then
  echo "=> Creating id_rsa"
  ssh-keygen -N '' -f /root/.ssh/id_rsa
fi

if [ -n "${INIT_BACKUP}" ]; then
  echo "=> Create a backup on the startup"
  /backup.sh
fi

echo "${CRON_TIME} /backup.sh >> /backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f
