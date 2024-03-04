#!/bin/sh


function dropDb()
{
    db_found=false  
    declare -a dbsList
    dbsList=($(ls -l databases | awk '/^d/ {print $NF}'))

    echo "--------------------------------------------------------"
    echo "Your Databases : "
    echo "--------------------------------------------------------"
    #----------------- list dbs in database dir--------------------
    for db in "${dbsList[@]}"
    do
        echo "- $db"
        echo ""
    done
    echo "--------------------------------------------------------"
    read -p "Please enter the name of DB you want to drop: " connectdb
    #----------------- check if the db is excisted--------------------
    for db in "${dbsList[@]}"
    do
        if [ "$connectdb" == "$db" ]
        then
            read -p "are you sure you want to delete $connectdb permenantly? [y/N] / [q] to quit : " -n 1 yes
            if [ "$yes" == 'y' ] || [ "$yes" == 'Y' ]
            then
                rm -r "./databases/$connectdb"
                db_found=true
            else
                quit $yes
            fi

        fi
    done
    break

    if [ "$db_found" == false ]
    then
        echo "You don't have a DB with this name."
        dropDb
    fi
}


function quit()
{
    if [ "$1" == 'q' ] || [ "$1" == 'Q' ]
    then
        . ./main-menu.sh    
    fi
}
dropDb