# PHP 7.3

Run script
```
docker run \
    -d \
    -p 80:80 \
    -p 3306:3306 \
    -v "$(pwd)"/html:/var/www \
    -v "$(pwd)"/db:/var/lib/mysql \
    tsndr/php:7.3
```
