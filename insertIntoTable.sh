#!/bin/bash

blue='\e[1;34m'
orange='\e[38;5;208m' 
yellow='\e[1;33m'
red='\e[1;31m'  
green='\e[1;32m'
reset='\e[0m'

insertIntoTable() {
   
    ../../listTables.sh

    echo -e "${orange}Which table do you want to insert data into? ${reset}"
    read tableToInsert

    # check if the table name is in DB
    if [ ! -f "$tableToInsert" ]
    then
        echo -e "${red}Error: Table with the name '$tableToInsert' does not exist in your DB.${reset}"
        tableMenu
    fi

    # check if metadata file exists
    metadata=".$tableToInsert-metadata"
    if [ ! -f "$metadata" ]
    then
        echo -e "${red}Error: Metadata file for table '$tableToInsert' not found.${reset}"
        tableMenu
    fi

    numFields=$(head -n 1 "$metadata") 2>/dev/null
    fieldNamesArr=($(sed -n '2p' "$metadata" | tr ':' ' ')) 2>/dev/null
    fieldTypesArr=($(sed -n '3p' "$metadata" | tr ':' ' ')) 2>/dev/null
    fieldPrimaryKeysArr=($(sed -n '4p' "$metadata" | tr ':' ' ')) 2>/dev/null

    #getting which field is primary
    for ((i = 0; i < ${#fieldPrimaryKeysArr[@]}; i++))
    do
        if [[ ${fieldPrimaryKeysArr[$i]} == "primary" ]]
        then
            primaryIndex=$i
            break
        fi
    done

   primaryField=$((primaryIndex+1))
   #echo $primaryField

   primaryFieldValues=($(awk -F ':' -v field=$primaryField '{print $field}' "$tableToInsert")) 2>/dev/null

    # display field names to the user
    echo "Fields to enter data: ${fieldNamesArr[@]}"

    # prompt the user to enter values for each field
    declare -a fieldValuesArr
    for ((i = 0; i < numFields; i++))
    do
        while true
        do
            # prompt the user to enter the value for the field
            read -p "Enter value for '${fieldNamesArr[$i]}': " fieldValue

            # check if it's empty
            if [[ $i -eq $primaryIndex && -z $fieldValue ]]
            then
                echo -e "${red}Error: Primary field cannot be null.${reset}"
            else
                # validation against if unique
                if [[ $i -eq $primaryIndex ]]
                then
                    uniqueVal=false

                   while ! $uniqueVal
                    do
                        # reset uniqueVal for each iteration
                        uniqueVal=true

                        # check if entered value already exists in the primary field values array
                        for value in "${primaryFieldValues[@]}"
                        do
                            if [[ "$fieldValue" == "$value" ]]
                            then
                                echo -e "${red}Error: Value for primary field already exists.${reset}"
                                read -p "Enter value for primary field '${fieldNamesArr[$primaryIndex]}': " fieldValue
                            
                                uniqueVal=false    # set uniqueVal to false if the value already exists
                                break
                            fi
                        done
                    done
                fi

                # validation against types
                if [[ ${fieldTypesArr[$i]} == "int" && ! $fieldValue =~ ^[0-9]+$ ]]
                then
                    echo -e "${red}Error: Value must be an integer for field '${fieldNamesArr[$i]}'.${reset}"
                elif [[ ${fieldTypesArr[$i]} == "string" && ! $fieldValue =~ ^[a-zA-Z0-9_-]+$ ]]
                then
                    echo -e "${red}Error: Value must be a string for field '${fieldNamesArr[$i]}'.${reset}"
                else
                    # value is valid, add it to the array and break out of the loop
                    fieldValuesArr[$i]=$fieldValue
                    break
                fi
            fi
        done
    done

    echo -e "${green}Inserting data into table '$tableToInsert' with values: ${fieldValuesArr[@]}${reset}"

    echo "${fieldValuesArr[*]}" | tr ' ' ':' >> "$tableToInsert" 
}

insertIntoTable
