#!/bin/bash

blue='\e[1;34m'
orange='\e[38;5;208m' 
yellow='\e[1;33m'
red='\e[1;31m'  
green='\e[1;32m'
reset='\e[0m'

main(){
	PS3="Please enter number of your choice: "

options=("Create Database" "List Database" "Connect to Database" "Drop Database" "Exit Program")

 echo -e "${blue}------------------------------------${reset}"
 echo -e "${blue}            Main Menu               ${reset}"
 echo -e "${blue}------------------------------------${reset}"

select option in "${options[@]}"
do
case $REPLY in
	1) clear
       echo -e "${orange}Creating DB...${reset}"
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
    5)  echo -e "${yellow}Exiting see you soon!...${reset}"
        exit 0
        ;; 
	*) echo -e "${red}Invalid option.. Please enter a choice from 1 to 5${reset}"
        ;;
esac
done
}

createDB() {
     if [ ! -w . ] 
     then
        echo -e "${red}Error: You do not have permission to create a database in current directory.${reset}"
        echo -e "${red}Please revise your permissions!${reset}"
        echo "------------------------------------"
        return
    fi

    read -p "Please enter Database Name: " dbName

    # check for spaces and special characters
    if [[ ! $dbName =~ ^[a-zA-Z0-9_]+$ ]]
	then
        echo -e "${red}Error: Database name cannot have space or special characters (only underscore)${reset}"
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

    if [ ! -d "./databases" ] || [ -z "$(ls -d ./databases/*/ 2>/dev/null)" ]

    then
        echo -e "${orange}No databases found.${reset}"
        echo "------------------------------------"
        main
    else
        if [ ! -r "./databases" ]
        then
            echo -e "${red}Error: You don't have permission to list databases.${reset}"
            echo -e "${red}Please revise your permissions!${reset}"
            echo "------------------------------------"
            return
        fi
        echo -e "${blue}\nList of Databases:${reset}"
        echo -e "${blue}------------------------------------${reset}"

        for dbDir in "./databases"/*/
        do
            echo "$(basename "$dbDir")"
        done 2>/dev/null     # redirecting stderr to /dev/null to suppress the error message
        echo -e "${blue}------------------------------------${reset}\n"
    fi
}

connectDb() {
    listDatabases
    while true
    do
        read -p "Please enter the name of DB you want to connect: [:q] to quit " connectdb
        quit $connectdb
        
        # check if the database name is empty
        if [ -z "$connectdb" ]
        then
            echo "Error: Database name cannot be empty."

        # check if the database exists
        elif [ -d "./databases/$connectdb" ]
        then
            cd "./databases/$connectdb"
            export connectdb
            clear
            source "../../tables.sh"
            break
        
        else
            echo -e "${red}You don't have a DB with this name${reset}"
            connectDb 
        fi
    done
}
function dropDb() {
    listDatabases
    read -p "Please enter the name of DB you want to drop: [:q] to quit " dropDb
    quit $dropDb  

    # Check if the database exists
    if [ -d "./databases/$dropDb" ]; then
        while true; do
            read -p "Are you sure you want to delete $dropDb permanently? [y/N] to quit : " -n 1 yes
            echo ""  # Ensure newline for readability
            case $yes in
                [yY])
                    rm -r "./databases/$dropDb"
                    echo -e "${green}$dropDb is deleted successfully${reset}"
                    main 
                    break  
                    ;;
                [nN])
                    main
                    break  
                    
                    ;;
                *)
                    echo -e "${red}Invalid choice. Please enter 'y' or 'q'.${reset}"
                    
                    ;;
            esac
        done
    else
        echo -e "${red}You don't have a DB with this name.${reset}"
        dropDb
    fi
}
# function dropDb()
# {
#     listDatabases
#     read -p "Please enter the name of DB you want to drop: [:q] to quit " dropDb
#     quit $dropDb
#     #----------------- check if the db is existed--------------------
#     if [ -d "./databases/$dropDb" ]
#     then
#         while true
#         do
#             read -p "Are you sure you want to delete $dropDb permanently? [y]/[q] to quit : " -n 1 yes
#             case $yes in
#                 [yY])
#                     rm -r "./databases/$dropDb"
#                     echo " "
#                     echo -e "${green}$dropDb is deleted successfully${reset}"
#                     ./main-menu.sh
#                     ;;
#                 [qQ])
#                     quit $yes
#                     ;;
#                 *)
#                     echo " "
#                     echo -e "${red}Invalid choice. Please enter 'y' or 'q'.${reset}"
#                     ;;
#             esac
#         done
        

#     fi
# }

function quit()
{
    if [ "$1" == ':q' ] || [ "$1" == ':Q' ]
    then
        echo "Quitting"
        main   
    fi
}

main

export yellow red orange blue green reset 
export -f main listDatabases