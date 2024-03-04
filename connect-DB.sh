#!/bin/sh

function connectDb()
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
    read -p "Please enter the name of DB you want to connect: " connectdb
    #----------------- check if the db is excisted--------------------
    for db in "${dbsList[@]}"
    do
        if [ "$connectdb" == "$db" ]
        then
            cd "./databases/$connectdb"
            db_found=true
            break
        fi
    done

    if [ "$db_found" == false ]
    then
        echo "You don't have a DB with this name."
        connectDb
    fi
}

connectDb


# dbsList=($(basename -a -s '/' ./Databases/*/))
# PS3="Which database do you want to connect? choose num from 1 to ${#dbsList[@]} "
# select db in "${dbsList[@]}" "Quit"
# do
#     case $db in
#         "Quit")
#             echo "Exiting."
#             break
#             ;;
#         *)
#             found=false
#             for ((i=0; i<${#dbsList[@]}; i++))
#             do
#                 if [ "$db" == "${dbsList[i]}" ]; then
#                     found=true
#                     echo "you selected: $db"
#                     break
#                 fi
#             done

#             if [ "$found" == false ]
#             then
#                 echo "You don't have that db."
#             fi
#             ;;
#     esac
# done

