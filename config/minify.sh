#!/usr/bin/env bash

src="src"
dist="dist"

for f in $(find $src/ -type f)
do
    p=$(dirname -- $f)
    f=$(basename -- $f)
    o="${p/$src/$dist}"
    if [ ! -d $o ]
    then
        mkdir -p $o
    fi
    printf "Processing $f ..."
    sed 's/\$/\\$/g' $p/$f > $o/$f
    sed -i 's/    /\\t/g' $o/$f
    sed -i 's/\t/\\t/g' $o/$f
    sed -i 's/\"/\\"/g' $o/$f
    sed -i ':a;N;$!ba;s/\n/\\n/g' $o/$f
    echo "echo \"$(cat $o/$f)\"" > $o/$f
    printf " ok\n"
done
