FROM alpine:3.7

#-------------------------------------------------------------------------------
#  Docker
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               docker

#-------------------------------------------------------------------------------
#  glibc (https://github.com/sgerrand/alpine-pkg-glibc)
#-------------------------------------------------------------------------------

ARG GLIBC_VERSION

RUN set -ex \
        && apk --no-cache add \
               curl \
        && curl --location \
               --output /etc/apk/keys/sgerrand.rsa.pub \
               https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
        && curl --location \
               --output /tmp/glibc-"${GLIBC_VERSION}".apk \
               https://github.com/sgerrand/alpine-pkg-glibc/releases/download/"${GLIBC_VERSION}"/glibc-"${GLIBC_VERSION}".apk \
        && apk --no-cache add \
               /tmp/glibc-"${GLIBC_VERSION}".apk \
        && rm /tmp/glibc-"${GLIBC_VERSION}".apk \
        && ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ \
        && ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib \
        && apk --no-cache del \
               curl

#-------------------------------------------------------------------------------
#  Docker Compose (https://github.com/docker/compose)
#-------------------------------------------------------------------------------

ARG COMPOSE_VERSION

RUN set -ex \
        && apk --no-cache add \
               curl \
        && curl --location \
               --output /usr/local/bin/docker-compose \
               https://github.com/docker/compose/releases/download/"${COMPOSE_VERSION}"/docker-compose-`uname -s`-`uname -m` \
        && chmod +x /usr/local/bin/docker-compose \
        && apk --no-cache del \
               curl

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               tzdata

COPY app-backup.sh /usr/local/bin/app-backup
COPY app-restore.sh /usr/local/bin/app-restore
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/app-backup \
        && chmod +x /usr/local/bin/app-restore \
        && chmod +x /usr/local/bin/docker-entrypoint

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
