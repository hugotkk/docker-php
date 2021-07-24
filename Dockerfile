FROM php:8.0.8-fpm-alpine3.14

# Optional, force UTC as server time
RUN echo "Asia/Hong_Kong" > /etc/timezone

RUN apk add --no-cache \
imagemagick

# Setup GD extension
RUN apk add --no-cache \
freetype \
libjpeg-turbo \
libpng \
freetype-dev \
libjpeg-turbo-dev \
libwebp-dev \
libpng-dev \
&& docker-php-ext-configure gd \
--with-freetype=/usr/include/ \
--with-jpeg=/usr/include/ \
&& docker-php-ext-install -j$(nproc) gd \
&& docker-php-ext-enable gd \
&& apk del --no-cache \
freetype-dev \
libjpeg-turbo-dev \
libpng-dev \
&& rm -rf /tmp/*

# Install intl extension
RUN apk add --no-cache \
icu-dev \
gettext \
gettext-dev \
&& docker-php-ext-install -j$(nproc) intl gettext \
&& docker-php-ext-enable intl gettext \
&& rm -rf /tmp/*

# Install mbstring extension
RUN apk add --no-cache \
oniguruma-dev \
&& docker-php-ext-install mbstring \
&& docker-php-ext-enable mbstring \
&& rm -rf /tmp/*

# Install opcache
ENV PHPIZE_DEPS \
autoconf \
dpkg-dev dpkg \
file \
g++ \
gcc \
libc-dev \
make \
pkgconf \
re2c

RUN apk add --no-cache --update --virtual \
.phpize-deps $PHPIZE_DEPS \
&& docker-php-source extract \
&& docker-php-ext-install opcache \
&& docker-php-ext-enable opcache \
&& docker-php-source delete \
&& rm -rf /tmp/*

# Install Memcached
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

RUN apk add --no-cache --update --virtual \
.memcached-deps $MEMCACHED_DEPS \
&& docker-php-source extract \
&& pecl install memcached \
&& docker-php-ext-enable memcached \
&& docker-php-source delete \
&& rm -rf /tmp/*

# Install LDAP
RUN apk add --no-cache \
ldb-dev \
libldap \
openldap-dev \
&& docker-php-ext-install ldap \
&& docker-php-ext-enable ldap \
&& rm -rf /tmp/*

# Install mysqli pdo
RUN docker-php-ext-install mysqli pdo \
&& docker-php-ext-enable mysqli pdo \
&& rm -rf /tmp/*

# Install zip
RUN apk add --no-cache \
libzip-dev \
libmcrypt-dev \
&& docker-php-ext-install zip \
&& docker-php-ext-enable zip \
&& rm -rf /tmp/*

# Locale
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
RUN apk add --no-cache \
$MUSL_LOCALE_DEPS
