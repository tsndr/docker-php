#!/bin/bash

export="min"
mkdir $export

for f in *.conf
do
    printf "Processing $f ..."
    sed 's/\$/\\$/g' $f > $export/$f
    sed -i 's/    /\\t/g' $export/$f
    sed -i 's/\t/\\t/g' $export/$f
    sed -i ':a;N;$!ba;s/\n/\\n/g' $export/$f
    printf " ok\n"
done