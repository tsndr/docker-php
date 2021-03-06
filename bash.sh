#!/usr/bin/env bash

docker run \
    -it \
    -p 80:80 \
    -v "$(pwd)"/html:/var/www \
    -v "$(pwd)"/db:/var/lib/mysql \
    tsndr/php:7.3 bash
