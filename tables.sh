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

        1) clear
           ../../listTables.sh
           tableMenu
         ;;
        2) clear
           ../../createTable.sh
           tableMenu
        ;;
        3) clear 
          ../../insertIntoTable.sh 
          tableMenu
        ;;
        4) echo "DropTable"
        ;;
        5) clear
           ../../selectFromTable.sh
           echo "selectFromTable" 
        ;;
        6) echo "deleteFromTable"
        ;;
        7) echo "updateTable"
        ;;
        8) echo "Exiting Table Menu..."
           cd ../../
           source "main-menu.sh"
        ;;
        *) echo "Invalid option.. Please enter a choice from 1 to 8" 
        ;;
        esac
    done
}

export -f tableMenu

# calling the menu function
tableMenu
