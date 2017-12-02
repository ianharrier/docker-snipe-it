FROM alpine:3.7

MAINTAINER Ian Harrier <github@harrier.us>

#-------------------------------------------------------------------------------
#  Apache
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               apache2 \
        && sed -i 's/^ServerTokens .*/ServerTokens Prod/g' /etc/apache2/httpd.conf \
        && sed -i 's/^ServerSignature .*/ServerSignature Off/g' /etc/apache2/httpd.conf \
        && sed -i 's/^#ServerName .*/ServerName localhost/g' /etc/apache2/httpd.conf \
        && ln -sf /dev/stdout /var/log/apache2/access.log \
        && ln -sf /dev/stderr /var/log/apache2/error.log \
        && mkdir -p /run/apache2

#-------------------------------------------------------------------------------
#  PHP
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               php7-apache2 \
               php7 \
               php7-bcmath \
               php7-ctype \
               php7-curl \
               php7-dom \
               php7-fileinfo \
               php7-gd \
               php7-json \
               php7-ldap \
               php7-mbstring \
               php7-mcrypt \
               php7-openssl \
               php7-pdo \
               php7-pdo_mysql \
               php7-phar \
               php7-session \
               php7-tokenizer \
               php7-simplexml \
               php7-xml \
               php7-zip \
               php7-zlib \
        && sed -i 's/^expose_php = .*/expose_php = Off/g' /etc/php7/php.ini \
        && sed -i 's/DirectoryIndex /DirectoryIndex index.php /g' /etc/apache2/httpd.conf

#-------------------------------------------------------------------------------
#  Composer (https://github.com/composer/composer)
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               curl \
        && curl --location --retry 3 \
               https://getcomposer.org/installer \
             | php -- --install-dir=/usr/local/bin --filename=composer \
        && apk --no-cache del \
               curl

#-------------------------------------------------------------------------------
#  Snipe-IT (https://github.com/snipe/snipe-it)
#-------------------------------------------------------------------------------

ARG SNIPEIT_VERSION

WORKDIR /srv/www/app

RUN set -ex \
        && apk --no-cache add \
               ca-certificates \
               curl \
               tar \
        && curl --location --retry 3 \
               https://github.com/snipe/snipe-it/archive/v${SNIPEIT_VERSION}.tar.gz \
             | tar -xz --strip-components=1 --no-same-owner \
        && sed -i 's|/var/www/localhost/htdocs|/srv/www/app/public|g' /etc/apache2/httpd.conf \
        && sed -i 's/^#LoadModule rewrite_module /LoadModule rewrite_module /g' /etc/apache2/httpd.conf \
        && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/httpd.conf \
        && sed -i 's/^allow_url_include = .*/allow_url_include = On/g' /etc/php7/php.ini \
        && echo "TLS_CACERT /etc/ssl/certs/ca-certificates.crt" >> /etc/openldap/ldap.conf \
        && composer install --no-dev \
        && rm -rf /root/.composer/cache \
        && mkdir -p /var/lib/snipeit/private_uploads \
        && rm -rf ./storage/private_uploads \
        && ln -sf /var/lib/snipeit/private_uploads ./storage/private_uploads \
        && mkdir -p /var/lib/snipeit/uploads \
        && rm -rf ./public/uploads \
        && ln -sf /var/lib/snipeit/uploads ./public/uploads \
        && chgrp -R apache storage /var/lib/snipeit/private_uploads /var/lib/snipeit/uploads \
        && chmod -R ug+rwx storage /var/lib/snipeit/private_uploads /var/lib/snipeit/uploads \
        && cp .env.example .env \
        && apk --no-cache del \
               curl \
               tar

EXPOSE 80

CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
