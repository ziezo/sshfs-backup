FROM alpine:3.7

COPY ["run.sh", "backup.sh", "/"]

RUN apk add --update \
     bash \
     gzip \
     sshfs \
&& rm -rf /var/cache/apk/* \ 
&& mkdir /backup \
&& chmod u+x /backup.sh \
&& mkdir /root/.ssh \
&& chmod 700 /root/.ssh

ENV CRON_TIME="0 3 * * sun" 

CMD ["/run.sh"]
