#!/bin/bash
red='\e[1;31m'
blue='\e[1;34m'
green='\e[1;32m'
reset='\e[0m'

deleteFromTable() {
    PS3="Enter option: "

    # List available tables
    ../../listTables.sh

    read -p "$(echo -e "${red}Which table do you want to delete from? [q] to quit: ${reset}")" table

    if [ "$table" == 'q' ] || [ "$table" == 'Q' ]; then
        echo "You pressed quit."
        ../../tables.sh
        return
    elif [ -f "$table" ]; then
        select option in "Delete all records" "Delete specific row" "Exit"; do
            case $REPLY in
                1)
                    echo -n > "$table"
                    clear
                    echo -e "${green}$table is now empty${reset}"
                    
                    ;;
                2)
                    deleteRow "$table"
                    ;;
                3)
                    echo "Exiting."
                    exit 0
                    ;;
                *)
                    echo "Invalid input."
                    ;;
            esac
            ../../tables.sh
        done
    else
        echo "Table '$table' does not exist."
        deleteFromTable
    fi
}

deleteRow() {
    local table="$1"
    local metadata_file=".$table-metadata"
    local data_file="$table"
    numFields=$(head -n 1 "$metadata_file") 2>/dev/null
    fieldNamesArr=($(awk -F: 'NR==2 {for (i=1; i<=NF; i++) print i"-"$i }' "$metadata_file"))

    echo -e "Fields in table $table:\n${fieldNamesArr[@]}"
    read -p "$(echo -e "${blue}Which column ([q] to quit): ${reset}")" col
    # if [ "$col" == 'q' ] || [ "$col" == 'Q' ]
    # then
    #     echo ""
    #     return  
    
    # elif
    if [[ $col -gt 0 ]] && [[ $col -le $numFields ]]
    then
        desiredcol=$(echo "${fieldNamesArr[$col-1]}" | awk -F- '{print $2}')
        read -p "$(echo -e "${blue}Where value ([q] to quit): ${reset}")" val
        if $(cut -d: -f"$col" "$table" | grep -q "^$val$")
        then
        
            line_numbers=$(awk -F: -v col="$col" -v val="$val" '$col == val {printf "%sd;", NR}' "$table")
            line_numbers=${line_numbers%?}  # Remove the trailing semicolon, if any  -> because of last one

            sed -i "$(echo $line_numbers)" "$table"
                
                echo -e "${green}Rows with '$desiredcol' = '$val' deleted successfully${reset}"
                tableMenu
        else
            echo -e "${red}Value $val not found in column $desiredcol${reset}"
            deleteRow $table
        fi
    else 
        echo -e "${red}Please enter existing column from 1 to $numFields${reset}"
        deleteRow $table
    fi

    }

deleteFromTable
exit 0



