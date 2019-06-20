#!/usr/bin/env bash
if [ ! $(find db/ -type f ) ]; then
    mysql_install_db
fi
mysqld