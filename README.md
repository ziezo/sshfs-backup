## sshfe-backup

Docker Hub: [ziezo/sshfs-backup](https://hub.docker.com/r/ziezo/sshfs-backup/)

Backup to sshfs

### Setup

#### .env

```
BACKUP_HOSTNAME=SOURCEHOST
BACKUP_TARGET=USER@TARGETHOST:PATH
BACKUP_CRON=0 1 * * *
```

#### docker-compose.yml

```yaml
version: "2.3"
services:
  sshfs-backup:
    container_name: sshfs-backup
    hostname: ${BACKUP_HOSTNAME}
    image: ziezo/sshfs-backup
    privileged: true
    volumes:
    - ./sshfs-backup/backup.conf:/backup.conf
    - ./sshfs-backup/ssh:/root/.ssh
    - /:/host:ro
    - /etc/localtime:/etc/localtime:ro
    environment:
    - "SSHFS_TARGET=${BACKUP_TARGET}"
    - "CRON_TIME=${BACKUP_CRON}"
    restart: always
```

#### backup.conf

```
#backup.conf
#on each line put backup file name + tar arguments, paths to backup
#paths are relative to / - do NOT use starting / !! (eg use 'home' and not '/home')
#lines starting with # and empty lines are ignored

#backup /etc and /root to 20181231-hostname-etc+root.tgz
etc+root           etc root

#backup /home excluding /home/user to 20181231-hostname-home-except-user.tgz
home-except-user  --exclude=home/user home
```

#### create ssh keys

```bash
cd sshfs-backup/ssh
ssh-keygen -f id_rsa -t rsa -N ''

#place id_rsa.pub in authorized keys of remote host:  
cat id_rsa.pub | ssh __REMOTE_HOST__ "tee -a __REMOTE_HOME_DIR__/.ssh/authorized_keys"
```

#### start container

`docker-compose up -d`



### Backup Target Server Setup

Tested on Debian 9 (stretch)

edit /etc/ssh/sshd_config

NOTES:
- internal-sftp does not need chroot files, sftp-server does need them
- the chroot dir has to be owned by root with 755 permissions

comment out the existing line: Subsystem sftp /usr/lib/openssh/sftp-server

append
```
#===========================
#sftp config
Subsystem sftp internal-sftp

Match User bakuser
    ChrootDirectory /bak/external
    X11Forwarding no
    AllowTCPForwarding no
    ForceCommand internal-sftp

#===========================
#OPTIONAL: allow root password authentication, disable for other users
PasswordAuthentication no
Match User root
PasswordAuthentication yes
```

Setup backup user + incoming backup write-only directory

```
#create user (no shell, but needs a home directory)  
adduser --shell /bin/false --home /home/bakuser bakuser

#create directories 
mkdir /bak/external
chown root.root /bak/external
chmod 755 /bak/external
mkdir /bak/external/incoming
chown root.root /bak/external/incoming
chmod 333 /bak/external/incoming

#restart ssh
service ssh restart
```
