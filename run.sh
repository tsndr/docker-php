#!/bin/bash

docker run \
    -d \
    -p 80:80 \
    -v "$(pwd)"/html:/var/www \
    tsndr/php:7.3