#!/bin/bash

# main menu for tables inside connected DB
tableMenu() {
    PS3="Please enter the number of your choice: "
    tableOptions=("List Tables" "Create Table" "Insert in table" "Select from table" "Delete from table" "Update from table" "Exit")

    echo "------------------------------------"
    echo "          Table Menu"
    echo "------------------------------------"

    select tableOption in "${tableOptions[@]}"
    do
        case $REPLY in
        1) listTables
         ;;
        2) echo "createTable" 
        ;;
        3) echo "insertIntoTable" 
        ;;
        4) echo "selectFromTable" 
        ;;
        5) echo "deleteFromTable"
        ;;
        6) echo "updateTable"
        ;;
        7) echo "Exiting Table Menu..."
           cd ../../
           source "main-menu.sh"
        ;;
        *) echo "Invalid option.. Please enter a choice from 1 to 7" 
        ;;
        esac
    done
}

# function to list tables
listTables() {
    echo "List of Tables:"
    echo "------------------------------------"

    for table in *
    do
        if [ -f "$table" ]
        then
            echo "$(basename "$table")"
        fi
    done

    echo "------------------------------------"
}


# calling the menu function
tableMenu
