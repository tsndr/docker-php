FROM debian:stretch-slim

# Fixing apt
RUN echo "Acquire::http::Pipeline-Depth 0; \
Acquire::http::No-Cache true; \
Acquire::BrokenProxy    true;" > /etc/apt/apt.conf.d/99fixbadproxy

# Installing php dependencies
RUN apt-get update &&\
    apt-get install -y build-essential git autoconf wget curl libxml2-dev libssl-dev pkg-config libbz2-dev libcurl4-openssl-dev libenchant-dev libjpeg-dev libpng-dev libfreetype6-dev libmcrypt-dev libpspell-dev libreadline-dev libxslt1-dev libzip-dev libc-client-dev libkrb5-dev m4

# Building bison
RUN cd /usr/local/src/ &&\
    wget http://ftp.gnu.org/gnu/bison/bison-2.7.tar.gz &&\
    tar xfz bison-2.7.tar.gz &&\
    rm bison-2.7.tar.gz &&\
    cd /usr/local/src/bison-2.7 &&\
    ./configure \
        --prefix=/usr/local/bison \
        --with-libiconv-prefix=/usr/local/libiconv/ &&\
    make &&\
    make install &&\
    make clean
RUN ln -s /usr/local/bison/bin/bison /usr/bin/bison
RUN ln -s /usr/local/bison/bin/yacc /usr/bin/yacc

# Building php cli
RUN cd /usr/local/src &&\
    git clone http://git.php.net/repository/php-src.git php &&\
    cd php &&\
    git checkout PHP-7.3 &&\
    ./buildconf \
        --force &&\
    ./configure \
        --prefix=/opt/php \
        --without-pear \
        --with-bz2 \
        --with-zlib \
        --enable-zip \
        --with-openssl \
        --with-curl \
        --enable-ftp \
        --with-pdo-mysql \
        --with-mysql-sock=/var/run/mysqld/mysqld.sock \
        --with-mysqli \
        --enable-sockets \
        --enable-pcntl \
        --with-pspell \
        --with-enchant \
        --with-gettext \
        --with-gd \
        --enable-exif \
        --with-jpeg-dir \
        --with-png-dir \
        --with-freetype-dir \
        --with-xsl \
        --enable-bcmath \
        --enable-mbstring \
        --enable-calendar \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --with-readline \
        --enable-intl \
        --enable-soap \
        --with-imap \
        --with-imap-ssl \
        --with-kerberos &&\
    make &&\
    make install &&\
    make clean &&\
    ln -s /opt/php/bin/php /usr/local/bin/php

# Building php fpm
RUN cd /usr/local/src/php &&\
    ./configure \
        --prefix=/opt/php \
        --with-bz2 \
        --with-zlib \
        --enable-zip \
        --with-openssl \
        --with-curl \
        --enable-ftp \
        --with-pdo-mysql \
        --with-mysql-sock=/var/run/mysqld/mysqld.sock \
        --with-mysqli \
        --enable-sockets \
        --enable-pcntl \
        --with-pspell \
        --with-enchant \
        --with-gettext \
        --with-gd \
        --enable-exif \
        --with-jpeg-dir \
        --with-png-dir \
        --with-freetype-dir \
        --with-xsl \
        --enable-bcmath \
        --enable-mbstring \
        --enable-calendar \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --disable-cli \
        --enable-fpm \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --enable-intl \
        --enable-soap \
        --with-imap \
        --with-imap-ssl \
        --with-kerberos \
        --without-pear &&\
    make &&\
    make install &&\
    make clean &&\
    ln -s /opt/php/sbin/php-fpm /usr/local/sbin/php-fpm &&\
    cp /usr/local/src/php/php.ini-production /opt/php/lib/php.ini &&\
    sed -i 's/; Local Variables:/; Local Variables:\nmemory_limit=256M\nupload_max_filesize=100M\npost_max_filesize=110M\n/' /opt/php/lib/php.ini &&\
    cp /opt/php/etc/php-fpm.conf.default /opt/php/etc/php-fpm.conf &&\
    cp /opt/php/etc/php-fpm.d/www.conf.default /opt/php/etc/php-fpm.d/www.conf

# Installing mysql server
RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update &&\
    apt-get install -y mysql-server &&\
    /etc/init.d/mysql start

# TODOs
# - Create FPM pool config
# - Install MySQL
# - Install NGINX
# - Create NGINX config

# CMD ["php", "-a"]
#CMD ["php", "--version"]
CMD ["php-fpm", "--nodaemonize", "--fpm-config", "/opt/php/etc/php-fpm.conf", "--allow-to-run-as-root"]
