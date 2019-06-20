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
    make clean &&\
    ln -s /usr/local/bison/bin/bison /usr/bin/bison &&\
    ln -s /usr/local/bison/bin/yacc /usr/bin/yacc

# Building php cli
RUN cd /usr/local/src &&\
    git clone https://github.com/php/php-src.git php &&\
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
    sed -i 's/; Local Variables:/; Local Variables:\ndate.timezone=Europe\/Berlin\nmemory_limit=256M\nupload_max_filesize=100M\npost_max_filesize=110M\n/' /opt/php/lib/php.ini &&\
    cp /opt/php/etc/php-fpm.conf.default /opt/php/etc/php-fpm.conf &&\
    echo "[www]\nuser = www-data\ngroup = www-data\nlisten = /var/run/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data\npm = ondemand\npm.max_children = 50\npm.process_idle_timeout = 10s\npm.max_requests = 500" > /opt/php/etc/php-fpm.d/www.conf

# Installing nginx
RUN apt-get install -y nginx &&\
    echo "server {\n\tlisten 80;\n\tlisten [::]:80;\n\tserver_name _;\n\taccess_log off;\n\terror_log off;\n\troot /var/www;\n\tindex index.php index.html;\n\tclient_max_body_size 30M;\n\tlocation ~* \.php\$ {\n\t\ttry_files\t\t\$uri /index.php;\n\t\tfastcgi_index\tindex.php;\n\t\tfastcgi_pass\tunix:/var/run/php-fpm.sock;\n\t\tinclude\t\t\tfastcgi_params;\n\t\tfastcgi_param\tSCRIPT_FILENAME\t\t\$document_root\$fastcgi_script_name;\n\t\tfastcgi_param\tSCRIPT_NAME\t\t\t\$fastcgi_script_name;\n\t\tfastcgi_read_timeout 600;\n\t}\n\tlocation / {\n\t\ttry_files \$uri \$uri/ =404;\n\t\tallow all;\n\t}\n\tlocation ~ /.well-known {\n\t\tallow all;\n\t}\n\tlocation ~ /\.ht {\n\t\tdeny all;\n\t\treturn 404;\n\t}\n}" > /etc/nginx/sites-available/default

# Installing mysql server
RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get install -y mysql-server

# Installing supervisor
RUN apt-get install -y supervisor &&\
    echo "[supervisord]\nnodaemon=true\n\n[program:nginx]\ncommand=nginx -g \"daemon off;\"\nkillasgroup=true\nstopasgroup=true\nredirect_stderr=true\n\n[program:mysql]\ncommand=mysqld\nkillasgroup=true\nstopasgroup=true\nredirect_stderr=true\n\n[program:php-fpm]\ncommand=php-fpm --nodaemonize --fpm-config /opt/php/etc/php-fpm.conf\nkillasgroup=true\nstopasgroup=true\nredirect_stderr=true" > /etc/supervisor/supervisord.conf

EXPOSE 80
CMD /usr/bin/supervisord
