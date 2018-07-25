FROM alpine:3.7

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               mariadb-client \
               tzdata

COPY app-backup.sh /usr/local/bin/app-backup
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/app-backup \
        && chmod +x /usr/local/bin/docker-entrypoint

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
