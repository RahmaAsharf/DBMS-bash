#!/bin/bash

# function to list tables
listTables() {

    tablesExist=0

    echo "List of Tables:"
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