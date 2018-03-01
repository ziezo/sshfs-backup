#backup to sshfs

edit docker-compose.yml

edit backup.conf

create ssh keys:
`cd sshfs/ssh`
`ssh-keygen -f id_rsa -t rsa -N ''`

place id_rsa.pub in authorized keys of remote host:
`cat id_rsa.pub | ssh __REMOTE_HOST__ "tee -a __REMOTE_HOME_DIR__/.ssh/authorized_keys"`

edit docker-compose.yml

`docker-compose up -d`

