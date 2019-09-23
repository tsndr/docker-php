#!/usr/bin/env bash

docker run \
    --name docker-php \
    -d \
    -p 80:80 \
    -p 3306:3306 \
    -v "$(pwd)"/html:/var/www \
    -v "$(pwd)"/db:/var/lib/mysql \
    tsndr/php:7.3
