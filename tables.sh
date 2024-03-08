#!/bin/bash

# main menu for tables inside connected DB
tableMenu() {
    PS3="Please enter the number of your choice: "
    tableOptions=("List Tables" "Create Table" "Insert in table" "Drop table" "Select from table" "Delete from table" "Update from table" "Exit")

    echo "------------------------------------"
    echo "          Table Menu"
    echo "------------------------------------"

    select tableOption in "${tableOptions[@]}"
    do
        case $REPLY in
        1) ../../listTables.sh
           tableMenu
         ;;
        2) ../../createTable.sh
            #echo $PWD
           tableMenu
        ;;
        3) echo "insertIntoTable" 
        ;;
        4) echo "DropTable"
        ;;
        5) echo "selectFromTable" 
        ;;
        6) ../../delFromTable.sh
        ;;
        7) ../../updateTable.sh
            #tableMenu
        ;;
        8) echo "Exiting Table Menu..."
           cd ../../
           source "main-menu.sh"
        ;;
        *) echo "Invalid option.. Please enter a choice from 1 to 7" 
        ;;
        esac
    done
}

# calling the menu function
tableMenu
