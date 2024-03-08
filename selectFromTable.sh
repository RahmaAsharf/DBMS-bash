#!/bin/bash

# to select all data from the table
select_all() {

    ../../listTables.sh

    read -p "Which table do you want to select from? " tableToSelect
    metadataFile=".$tableToSelect-metadata"
     # check if the table name is in DB
    if [ ! -f "$tableToSelect" ]
    then
        echo "Error: Table with the name '$tableToSelect' does not exist in your DB."
        selectFromTable
    fi

    # check if metadata file exists
    metadataFile=".$tableToSelect-metadata"
    if [ ! -f "$metadataFile" ]
    then
        echo "Error: Metadata file for table '$tableToSelect' not found."
        selectFromTable
    fi
  
    fields=($(sed -n '2p' "$metadataFile" | tr ':' ' '))
 
    echo -e "\033[1;34m\n*********************** Table $tableToSelect *************************\033[0m"
    echo -e "\033[1;34m************************************************************\033[0m"

 for ((i=0; i<${#fields[@]}; i++))
do
    printf "\033[1;33m%-15s\033[0m" "${fields[$i]}"  
done
    echo -e "\033[1;34m\n************************************************************\033[0m"
    awk -F ':'  'NR >= 1 {
                printf "\n"
                for (i=1; i<=NF; i++) {
                    printf "%-15s", $i
                }
                printf "\n"
            }' $tableToSelect

    echo -e "\033[1;34m\n************************************************************\n\n\033[0m"
    
   
}



# menu to select from
selectFromTable() {
    PS3="Please select an option: "
    options=("Select all" "Select by column (projection)" "Select rows (selection) with condition" "Exit")

    echo "------------------------------------"
    echo "          Select from Table"
    echo "------------------------------------"

    select option in "${options[@]}"
    do
        case $REPLY in
            1) select_all 
               selectFromTable
            ;;
            2) echo "projection"
            ;;
            3) echo "selection"  
            ;;
            4) tableMenu
               echo "Exiting..." 
            break ;;
            *) echo "Invalid option. Please select a number from 1 to 4." ;;
        esac
    done
}


selectFromTable
