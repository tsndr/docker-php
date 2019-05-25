#!/bin/bash

export="min"
mkdir -p $export

for f in *.conf
do
    printf "Processing $f ..."
    sed 's/\$/\\$/g' $f > $export/$f
    sed -i 's/    /\\t/g' $export/$f
    sed -i 's/\t/\\t/g' $export/$f
    sed -i 's/\"/\\"/g' $export/$f
    sed -i ':a;N;$!ba;s/\n/\\n/g' $export/$f
    echo "echo \"$(cat $export/$f)\"" > $export/$f
    printf " ok\n"
done