#!/bin/bash

blue='\033[1;34m'
yellow='\033[1;33'
red='\033[1;31m'  
reset='\033[0m'


# to select all data from the table
select_all() {

   ../../listTables.sh

    read -p "Which table do you want to select from? " table
    metadata=".$table-metadata"
     # check if the table name is in DB
    if [ ! -f "$table" ]
    then
        echo -e "${red}Error: Table with the name '$table' does not exist in your DB.${reset}"
        selectFromTable
    fi

    # check if metadata file exists
    metadata=".$table-metadata"
    if [ ! -f "$metadata" ]
    then
        echo -e "${red}Error: Metadata file for table '$table' not found.${reset}"
        selectFromTable
    fi
  
    fields=($(sed -n '2p' "$metadata" | tr ':' ' '))
 
    echo -e "${blue}\n*********************** Table $table *************************${reset}"
    echo -e "${blue}************************************************************${reset}"

    for ((i=0; i<${#fields[@]}; i++))
    do
        printf "${yellow}m%-15s${reset}" "${fields[$i]}"  
    done

    echo -e "${blue}\n************************************************************${reset}"
    awk -F ':'  'NR >= 1 {
                printf "\n"
                for (i=1; i<=NF; i++) {
                    printf "%-15s", $i
                }
                printf "\n"
            }' $table

    echo -e "${blue}\n************************************************************\n\n${reset}"
    
   
}

# to select by column (projection)
projection() {

    ../../listTables.sh

    read -p "Which table do you want to select from? " table
    metadata=".$table-metadata"

    if [ ! -f "$table" ]
    then
        echo -e "${red}Error: Table '$table' does not exist.${reset}"
        selectFromTable
    fi

    if [ ! -f "$metadata" ]
    then
        echo -e "${red}Error: Metadata file for table '$table' not found.${reset}"
        selectFromTable
    fi

    fields=($(sed -n '2p' "$metadata" | tr ':' ' '))

    # displays available columns 
    echo -e "\nAvailable columns for projection:"
    for ((i=0; i<${#fields[@]}; i++))
    do
        echo "$(($i+1)). ${fields[$i]}"
    done

    read -p "Enter column numbers separated by spaces: " cols

    # validate selected columns
    colExists=true
    for col in $cols
    do
        if [ "$col" -gt "${#fields[@]}" ] || [ "$col" -lt 1 ]
        then
            echo -e "${red}Error: Column number does not exist.${reset}"
            colExists=false
            break
        fi
    done

    if [ $colExists = false ]
    then
        return
    fi

    echo -e "${blue}\n*********************** Table $table *************************${reset}"
    echo -e "${blue}************************************************************${reset}"

    echo -e "${blue}Selected columns:${reset}"
    for col in $cols 
    do
        index=$(($col - 1))
        printf "${yellow}m%-16s${reset}" "${fields[$index]}"
    done

    #  printing selected columns
    echo -e "${blue}\n************************************************************${reset}"
    awk -F ':' -v cols="$cols" '{
        split(cols, splitCols, " ")
        for (i=1; i<=length(splitCols); i++) 
        {
            printf "%-15s ", $splitCols[i]
        }
        printf "\n"
    }' $table
    echo -e "${blue}\n************************************************************\n\n${reset}"
}

selection() {
     ../../listTables.sh

    read -p "Which table do you want to select from? " table
    metadata=".$table-metadata"

    if [ ! -f "$table" ]
    then
        echo -e "${red}Error: Table '$table' does not exist.${reset}"
        selectFromTable
    fi

    if [ ! -f "$metadata" ]
    then
        echo -e "${red}Error: Metadata file for table '$table' not found.${reset}"
        selectFromTable
    fi
    
    fields=($(sed -n '2p' "$metadata" | tr ':' ' '))

    # displays available columns 
    echo -e "\nAvailable columns for selection:"
    for ((i=0; i<${#fields[@]}; i++))
    do
        echo "$(($i+1)). ${fields[$i]}"
    done

     numFields=$(head -n 1 "$metadata") 2>/dev/null

     read -p $'\n\e\033[1;34mWhich column: \e\033[0m' col
 
    if [[ $col -gt 0 ]] && [[ $col -le $numFields ]]
    then
         read -p $'\n\e\033[1;34mWhich value: \e\033[0m' val

        if $(cut -d: -f"$col" "$table" | grep -q "^$val$")
        then
            echo -e "${blue}\n*********************** Table $table *************************${reset}"
            echo -e "${blue}************************************************************${reset}"
            echo -e "${blue}Value '$val' found in rows: ${reset}"
            for ((i=0; i<${#fields[@]}; i++))
            do
                printf "${yellow}m%-15s${reset}" "${fields[$i]}"  
            done
            echo -e "${blue}\n************************************************************${reset}"
            awk -F ':' -v col="$col" -v val="$val" '{ if ($col == val) 
            { for (i=1; i<=NF; i++) printf "%-15s", $i; printf "\n"} }' "$table"
            echo -e "${blue}************************************************************${reset}"

        else
            echo "Value $val not found in column $col"
        fi
    else 
        echo -e "${red}Please enter an existing column from 1 to $numFields${reset}"
    fi
}

# menu to select from
selectFromTable() {
    PS3="Please select an option: "
    options=("Select all" "Select by column (projection)" "Select rows (selection) with condition" "Exit")

    echo -e "${blue}------------------------------------${reset}"
    echo -e "${blue}       Select From Table Menu       ${reset}"
    echo -e "${blue}------------------------------------${reset}"

    select option in "${options[@]}"
    do
        case $REPLY in
            1) select_all 
               selectFromTable
            ;;
            2) projection 
              selectFromTable
            ;;
            3) selection
              selectFromTable
            ;;
            4) echo "Exiting select menu..." 
               tableMenu
               
            break ;;
            *) echo -e "${red}Invalid option. Please select a number from 1 to 4.${reset}" ;;
        esac
    done
}


selectFromTable
