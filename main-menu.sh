#!/bin/bash


main(){
	PS3="Please enter number of your choice: "

options=("Create Database" "List Database" "Connect to Database" "Drop Database" "Exit")

 echo "------------------------------------"
 echo "          Main Menu"
 echo "------------------------------------"

select option in "${options[@]}"
do
case $REPLY in
	1) echo "Creating DB"
       createDB
	   main
        ;;
	2) echo "Listing DBs"
       listDatabases
       main
	    ;;
	3) 
        connectDb
        ;;
	4) echo "Dropping DB"
        dropDb
        ;;
    5) echo "Exiting..."
        exit 0
        ;; 
	*) echo "Invalid option.. Please enter a choice from 1 to 5"
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
    if [ ! -d "./databases" ]
    then
        echo "No databases found."
        echo "------------------------------------"
    else
        echo "List of Databases:"
        echo "------------------------------------"

        # redirecting stderr to /dev/null to suppress the error message
        for dbDir in "./databases"/*/
        do
            echo "$(basename "$dbDir")"
        done 2>/dev/null
        echo "------------------------------------"
    fi
}

function connectDb()
{
    listDatabases
    echo "--------------------------------------------------------"
    read -p "Please enter the name of DB you want to connect: " connectdb

    #----------------- check if the db is excisted--------------------
    if [ -d "./databases/$connectdb" ]
    then
        cd "./databases/$connectdb"
        echo $PWD
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
    if [ -d "./databases/$connectdb" ]; then
        while true; do
            read -p "Are you sure you want to delete $connectdb permanently? [y]/[q] to quit : " -n 1 yes
            case $yes in
                [yY])
                    rm -r "./databases/$connectdb"
                    echo " "
                    echo "$connectdb is deleted successfully"
                    ./main-menu.sh
                    ;;
                [qQ])
                    quit $yes
                    ;;
                *)
                    echo " "
                    echo "Invalid choice. Please enter 'y' or 'q'."
                    ;;
            esac
        done
    else
        #---------------------------need to handle here
        echo "You don't have a DB with this name. Choose an existing one or [q] to quit."
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