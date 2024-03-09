#!/bin/bash

blue='\e[1;34m'
orange='\e[38;5;208m' 
reset='\e[0m'

listTables() {

    tablesExist=0

    echo -e "${blue}\nList of Tables:${reset}"
    echo -e "${blue}------------------------------------${reset}"

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
        echo -e "${orange}No tables found.${reset}"
    fi

    echo -e "${blue}------------------------------------${reset}\n"


}

listTables