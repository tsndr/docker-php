#!/usr/bin/env bash
if [ ! $(find db/ -type f ) ]; then
    mysql_install_db

    mysqld &> /dev/null &
    MYSQL_PID=$!

    echo "exit" | mysql &> /dev/null

    while [ "$?" != 0 ]; do
        sleep 5
        echo "exit" | mysql &> /dev/null
    done

    echo "grant all privileges on *.* to 'root'@'%' identified by 'root';use mysql;update user set Password = '', Grant_priv = 'Y' where User = 'root' and Host = '%';flush privileges;" | mysql

    kill $MYSQL_PID
fi
mysqld