#!/bin/bash


main(){
	PS3="Please enter number of your choice: "

options=("Create Database" "List Database" "Connect to Database" "Drop Database")


select option in "${options[@]}"
do
case $REPLY in
	1) echo "Creating DB"
       createDB
	   main
        ;;
	2) echo "Listing DBs"
	;;
	3) ./connect-DB.sh
        ;;
	4) echo "Dropping DB"
        ;;
	*) echo "Invalid option.. Please enter a choice from 1 to 4"
        ;;
esac
done
}

createDB() {
    read -p "Please enter Database Name: " dbName

    # check for spaces and special characters
    if [[ ! $dbName =~ ^[a-zA-Z0-9_]+$ ]]
	then
        echo "Error: Database name cannot have space or special characters"
        echo "------------------------------------"
        return
    fi

    # check if DB name starts with a letter
    if [[ ! $dbName =~ ^[a-zA-Z] ]]
	then
        echo "Error: Database name must start with a letter."
        echo "------------------------------------"
        return
    fi

    # check if DB already exists
    if [ -d "./databases/$dbName" ]
	then
        echo "Error: Database $dbName already exists."
        echo "------------------------------------"
        return
    fi

    # create the database dir
    mkdir -p "./databases/$dbName"
    if [ $? -eq 0 ]
	then
        echo "Database $dbName created successfully!"
        echo "------------------------------------"
    else
        echo "Error creating database $dbName."
    fi
}

listDatabases() {
    ls ./databases
}

main