#!/bin/bash

for i in $(seq 0 255) ; do
    printf "\x1b[48;5;%sm%8d\e[0m " "$i" "$i"
    if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
        printf "\n";
    fi
done
