#!/bin/bash

docker run \
    -it \
    -p 80:80 \
    -v "$(pwd)"/html:/var/www \
    tsndr/php:7.3 bash