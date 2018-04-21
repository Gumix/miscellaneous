#!/bin/bash

path=$1
exiftool='exiftool-5.26'

if [ $# -lt 1 ]
then
    echo -e "Usage:\t$0 path_to_photos"
    exit 1
fi

$exiftool -recurse -table -focallength "$path" | grep '[0-9\.]\+ mm' | sort --numeric-sort | uniq -c
