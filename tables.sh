#!/bin/bash

blue='\e[1;34m'
red='\e[1;31m'  
yellow='\e[1;33m'
orange='\e[38;5;208m' 
reset='\e[0m'

# main menu for tables inside connected DB
tableMenu() {
    PS3="Please enter the number of your choice: "
    tableOptions=("List Tables" "Create Table" "Insert in table" "Drop table" "Select from table" "Delete from table" "Update from table" "Exit Table Menu")

    echo -e "${orange}___________  In $connectdb DB ____________${reset}"
    echo -e "${blue}------------------------------------${reset}"
    echo -e "${blue}            Table Menu              ${reset}"
    echo -e "${blue}------------------------------------${reset}"

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
        6) ../../delFromTable.sh
            tableMenu
        ;;
        7) ../../updateTable.sh
            #tableMenu
        ;;
        8) echo -e "${orange}Exiting Table Menu...\n${reset}"
           cd ../../
           source "main-menu.sh"
        ;;
        *) echo -e "${red}Invalid option.. Please enter a choice from 1 to 8${reset}" 
        ;;
        esac
    done
}

export -f tableMenu

# calling the menu function
tableMenu
