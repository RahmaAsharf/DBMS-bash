#!/bin/sh

blue='\e[1;34m'
orange='\e[38;5;208m'
yellow='\e[1;33m'
red='\e[1;31m'
green='\e[1;32m'
reset='\e[0m'

function quit() {
    if [ "$1" == 'q' ] || [ "$1" == 'Q' ]
    then
        clear
        updateTable
    fi
}

function updateTable() {
    ../../listTables.sh

    while true
    do
        read -p "$(echo -e "${red}Which tableToUpdate do you want to update? [q] to quit: ${reset}")" tableToUpdate
        quit "$tableToUpdate"

        if [ "$tableToUpdate" == 'q' ] || [ "$tableToUpdate" == 'Q' ]
        then
            echo "You pressed quit."
            ../../tables.sh
        elif [ -f "$tableToUpdate" ] && [ -f ".$tableToUpdate-metadata" ]
        then
            # Variables initialization
            metadata=".$tableToUpdate-metadata"
            numFields=$(head -n 1 "$metadata" 2>/dev/null)
            fields=($(sed -n '2p' "$metadata" | tr ':' ' ' 2>/dev/null))
            fieldTypesArr=($(sed -n '3p' "$metadata" | tr ':' ' ' 2>/dev/null))
            fieldPrimaryKeysArr=($(sed -n '4p' "$metadata" | tr ':' ' ' 2>/dev/null))
            echo "${fieldTypesArr[0]}"

            for ((i = 0; i < ${#fieldPrimaryKeysArr[@]}; i++))
            do
                if [[ ${fieldPrimaryKeysArr[$i]} == "primary" ]]
                then
                    primaryIndex=$i
                    break
                fi
            done
            primaryField=$((primaryIndex + 1))

            # Listing columns in the table
            echo -e "\nColumns in table $tableToUpdate:"
            for ((i = 0; i < ${#fields[@]}; i++))
            do
                echo "$(($i + 1)). ${fields[$i]}"
            done

            # While loop for updating
            while true
            do
                read -p "$(echo -e "${blue}Which column you want to update by (select by number): [q] to quit: ${reset}")" colToUpdate
                quit "$colToUpdate"

                # Checking if the colToUpdate num is available
                if [[ $colToUpdate -gt 0 ]] && [[ $colToUpdate -le $numFields ]]
                then
                    while true
                    do
                        read -p "$(echo -e "${blue}Where value: [q] to quit: ${reset}")" val
                        quit "$val"

                        if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$")
                        then
                            while true
                            do
                                read -p "$(echo -e "${blue}To be Updated with: [q] to quit: ${reset}")" newVal
                                quit "$newVal"

                                # Checking if colToUpdate is PK
                                if [[ $colToUpdate -eq $primaryField ]]
                                then
                                    # Checking if it is null
                                    if [[ -z $newVal ]]
                                    then
                                        echo -e "${red}Error: Primary field cannot be null. Enter a valid value or 'q' to quit.${reset}"
                                        continue  # Go back to the previous loop
                                    # Checking if the newVal is unique
                                    elif $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$newVal$")
                                    then
                                        echo -e "${red}Error: '$newVal' already exists, Primary field must be unique. Enter a valid value or 'q' to quit.${reset}"
                                        continue  # Go back to the previous loop
                                    else
                                        break
                                    fi
                                else
                                    break
                                fi
                            done

                            while true; do
                                if [[ ${fieldTypesArr[$((colToUpdate - 1))]} == "int" && ! $newVal =~ ^[0-9]+$ ]]
                                then
                                    read -p "$(echo -e "${red}Error: Value must be an integer for field '${fields[$((colToUpdate - 1))]}'. Enter a valid value or 'q' to quit: ${reset}")" newVal
                                    quit "$newVal"
                                elif [[ ${fieldTypesArr[$((colToUpdate - 1))]} == "string" && ! $newVal =~ ^[[:alpha:]]+$ ]]
                                then
                                    read -p "$(echo -e "${red}Error: Value must be alpha characters only for field '${fields[$((colToUpdate - 1))]}'.' Enter a valid value or 'q' to quit: ${reset}")" newVal
                                    quit "$newVal"
                                else
                                    break
                                fi
                            done

                            # If everything is valid, update the table
                            if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$")
                            then
                                sed -i "s/$val/$newVal/g" "$tableToUpdate"
                                clear
                                echo -e "${green}Rows with '${fields[$colToUpdate - 1]}' = '$val' updated successfully${reset}"
                                updateTable
                            else
                                echo -e "${red}Value $val not found in column $colToUpdate${reset}"
                            fi
                        else
                            echo -e "${red}'$val' is not a valid value in column $colToUpdate, please pick a valid one or 'q' to quit.${reset}"
                        fi
                    done
                else
                    echo -e "${red}Please enter an existing column from 1 to $numFields or 'q' to quit.${reset}"
                fi
            done
        else
            echo -e "${red}Error: Table '$tableToUpdate' not found.${reset}"
        fi
    done
}

# Call the main function
updateTable
