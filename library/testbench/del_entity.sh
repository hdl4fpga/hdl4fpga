#!/bin/sh

state='start';
while read line ; do
    case $state in
    start)
        if [[ "$line" =~ ^entity.*"$1" ]] ; then
            state='cut'
            exit
        else
            echo "${line}"
        fi 
        ;;
    cut)
        if [[ "$line" =~ end ]] ; then
            state='end'
        fi
        ;;
    *)
        echo "${line}"
        ;;
    esac
done