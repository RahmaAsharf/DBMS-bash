#!/bin/sh

dbsList=($(basename -a -s '/' ./Databases/*/))
PS3="Which database do you want to connect? choose num from 1 to ${#dbsList[@]} "
select db in "${dbsList[@]}" "Quit"
do
    case $db in
        "Quit")
            echo "Exiting."
            break
            ;;
        *)
            found=false
            for ((i=0; i<${#dbsList[@]}; i++))
            do
                if [ "$db" == "${dbsList[i]}" ]; then
                    found=true
                    echo "you selected: $db"
                    break
                fi
            done

            if [ "$found" == false ]
            then
                echo "You don't have that db."
            fi
            ;;
    esac
done

