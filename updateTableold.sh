#!/bin/sh
blue='\e[1;34m'
orange='\e[38;5;208m' 
yellow='\e[1;33m'
red='\e[1;31m'  
green='\e[1;32m'
reset='\e[0m'
updateTable(){
    ../../listTables.sh
    
    read -p "$(echo -e "${red}Which tableToUpdate do you want to update? [q] to quit: ${reset}")" tableToUpdate

    if [ "$tableToUpdate" == 'q' ] || [ "$tableToUpdate" == 'Q' ]
    then
        echo "You pressed quit."
        ../../tables.sh
    else
        if [ -f "$tableToUpdate" ] && [ -f ".$tableToUpdate-metadata" ] 
        then
            #variables initialization
            metadata=".$tableToUpdate-metadata"
            numFields=$(head -n 1 "$metadata") 2>/dev/null
            fields=($(sed -n '2p' "$metadata" | tr ':' ' ')) 2>/dev/null #start with 0
            fieldTypesArr=($(sed -n '3p' "$metadata" | tr ':' ' ')) 2>/dev/null
            fieldPrimaryKeysArr=($(sed -n '4p' "$metadata" | tr ':' ' ')) 2>/dev/null
            echo "${fieldTypesArr[0]}"

            for ((i = 0; i < ${#fieldPrimaryKeysArr[@]}; i++))
            do
                if [[ ${fieldPrimaryKeysArr[$i]} == "primary" ]]
                then
                    primaryIndex=$i
                    break
                fi
            done
            primaryField=$((primaryIndex+1))

            #listing cols in table
            echo -e "\ncolumns in table $tableToUpdate:"
            for ((i=0; i<${#fields[@]}; i++))
            do
                echo "$(($i+1)). ${fields[$i]}"
            done

            #//////////////////while///////////
            read -p "$(echo -e "${blue}Which column you want to update by (select by number): ${reset}")" colToUpdate
            #checking if the colToUpdate num is avalible
            if [[ $colToUpdate -gt 0 ]] && [[ $colToUpdate -le $numFields ]]
            then
                read -p "$(echo -e "${blue}Where value: ${reset}")" val
                if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$")
                then
                    read -p "$(echo -e "${blue}To be Updated with: ${reset}")" newVal

                    #checking if colToUpdate is PK
                    if [[ $colToUpdate -eq $primaryField ]]
                    then
                        #to check if it is null
                        if [[ -z $newVal ]]
                        then
                            echo "Error: Primary field cannot be null."
                            updateTable
                        fi
                        #to check if the newVal is unique
                        if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$newVal$")
                        then
                            echo "Error: '$newVal' already exists, Primary field must be unique"
                            updateTable

                        fi
                    fi
                    #checking for type
                    if [[ ${fieldTypesArr[$((colToUpdate-1))]} == "int" && ! $newVal =~ ^[0-9]+$ ]]
                    then
                        echo "Error: Value must be an integer for field '${fields[$((colToUpdate-1))]}'."
                        
                    elif [[ ${fieldTypesArr[$((colToUpdate-1))]} == "string" && ! $newVal =~ ^[[:alpha:]]+$ ]]
                    then
                        echo "Error: Value must be a string for field '${fields[$((colToUpdate-1))]}'."

                    else

                        if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$") 
                        then
                            #awk -F: -v colToUpdate="$colToUpdate" -v val="$val" '$colToUpdate == val {print NR, $0}' "$table"
                            sed -i "s/$val/$newVal/g" "$tableToUpdate"
                            
                            echo -e "${green}Rows with '${fields[$colToUpdate-1]}' = '$val' updated successfully${reset}"

                        else
                            echo -e "${red}Value $val not found in column $colToUpdate${reset}"

                        fi
                    fi

                else
                #//////////
                    echo "'$val' is not a valid value in column $colToUpdate, please pick a valin one "
                    updateTable

                fi
                break
            else
                echo -e "${red}Please enter an existing column from 1 to $numFields${reset}"
            fi
        #//////done for while
        else
            echo "Error: Table '$tableToUpdate' not found."
            updateTable
        fi
    fi



}
updateTable