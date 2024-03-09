#!/bin/bash

blue='\e[1;34m'
orange='\e[38;5;208m' 
yellow='\e[1;33'
red='\e[1;31m'  
green='\e[1;32m'
reset='\e[0m'

main(){
	PS3="Please enter number of your choice: "

options=("Create Database" "List Database" "Connect to Database" "Drop Database" "Exit")

 echo -e "${blue}------------------------------------${reset}"
 echo -e "${blue}            Main Menu               ${reset}"
 echo -e "${blue}------------------------------------${reset}"

select option in "${options[@]}"
do
case $REPLY in
	1) echo -e "${orange}Creating DB...${reset}"
       createDB
	   main
        ;;
	2) clear
        listDatabases
       main
	    ;;
	3) clear
        connectDb
        ;;
	4) clear
        dropDb
        ;;
    5) clear
        echo "Exiting see you soon!..."
        exit 0
        ;; 
	*) echo -e "${red}Invalid option.. Please enter a choice from 1 to 5${reset}"
        ;;
esac
done
}

createDB() {
    read -p "Please enter Database Name: " dbName

    # check for spaces and special characters
    if [[ ! $dbName =~ ^[a-zA-Z0-9_]+$ ]]
	then
        echo -e "${red}Error: Database name cannot have space or special characters${reset}"
        echo "------------------------------------"
        return
    fi

    # check if DB name starts with a letter
    if [[ ! $dbName =~ ^[a-zA-Z] ]]
	then
        echo -e "${red}Error: Database name must start with a letter.${reset}"
        echo "------------------------------------"
        return
    fi

    # check if DB already exists
    if [ -d "./databases/$dbName" ]
	then
        echo -e "${red}Error: Database $dbName already exists.${reset}"
        echo "------------------------------------"
        return
    fi

    # create the database dir
    mkdir -p "./databases/$dbName"
    if [ $? -eq 0 ]
	then
        echo -e "${green}Database $dbName created successfully!${reset}"
        echo "------------------------------------"
    else
        echo -e "${red}Error creating database $dbName.${reset}"
    fi
}

listDatabases() {
    if [ ! -d "./databases" ]
    then
        echo -e "${orange}No databases found.${reset}"
        echo "------------------------------------"
    else
        echo -e "${blue}\nList of Databases:${reset}"
        echo -e "${blue}------------------------------------${reset}"

        # redirecting stderr to /dev/null to suppress the error message
        for dbDir in "./databases"/*/
        do
            echo "$(basename "$dbDir")"
        done 2>/dev/null
         echo -e "${blue}------------------------------------${reset}\n"
    fi
}

function connectDb()
{
    listDatabases
    read -p "Please enter the name of DB you want to connect: " connectdb

    #----------------- check if the db is excisted--------------------
    if [ -d "./databases/$connectdb" ]
    then
        cd "./databases/$connectdb"
        #echo $PWD
        export connectdb
        clear
        #echo $PWD
        source "../../tables.sh"

    else
        read -p "You don't have a DB with this name choose excisted one or [q] to quit : " op
        quit $op
        connectDb
    fi

}

function dropDb()
{
    listDatabases
    read -p "Please enter the name of DB you want to drop: " connectdb

    #----------------- check if the db is existed--------------------
    if [ -d "./databases/$connectdb" ]
    then
        while true
        do
            read -p "Are you sure you want to delete $connectdb permanently? [y]/[q] to quit : " -n 1 yes
            case $yes in
                [yY])
                    rm -r "./databases/$connectdb"
                    echo " "
                    echo -e "${green}$connectdb is deleted successfully${reset}"
                    ./main-menu.sh
                    ;;
                [qQ])
                    quit $yes
                    ;;
                *)
                    echo " "
                    echo -e "${red}Invalid choice. Please enter 'y' or 'q'.${reset}"
                    ;;
            esac
        done
    else
        echo -e "${orange} Please enter any key to re-choose or [q] to quit: ${reset}"
        dropDb
    fi
}

function quit()
{
    if [ "$1" == 'q' ] || [ "$1" == 'Q' ]
    then
        echo ""
        main   
    fi
}

main