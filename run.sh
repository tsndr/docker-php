#!/usr/bin/env bash

docker run \
    --name docker-php \
    -d \
    -p 8080:80 \
    -v "$(pwd)"/html:/var/www \
    -v "$(pwd)"/db:/var/lib/mysql \
    tsndr/php:7.3
