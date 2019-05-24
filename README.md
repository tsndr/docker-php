# PHP 7.3

Run script
```
docker run \
    -d \
    -p 80:80 \
    -v "$(pwd)"/data:/var/www \
    tsndr/php:7.3
```