#!/bin/bash

listTables() {

    tablesExist=0

    echo -e "\nList of Tables:"
    echo "------------------------------------"

    for table in *
    do
        if [ -f "$table" ]
        then
            echo "$(basename "$table")"
            tablesExist=1
        fi
    done

    if [ $tablesExist -eq 0 ] 
    then
        echo "No tables found."
    fi

    echo "------------------------------------"


}

listTables