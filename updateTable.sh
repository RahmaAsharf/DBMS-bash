#!/bin/sh

updateTable(){
    # List available tables
    ../../listTables.sh

    read -p "$(echo -e "${red}Which table do you want to update? [q] to quit: ${reset}")" table

    if [ "$table" == 'q' ] || [ "$table" == 'Q' ]; then
        echo "You pressed quit."
        ../../tables.sh
    else
        if [ -f "$table" ]
        then
            if [ -f ".$table-metadata" ] 
            then
                metadataFile=".$table-metadata"

                numFields=$(head -n 1 "$metadataFile") 2>/dev/null
                fieldTypesArr=($(sed -n '3p' "$metadataFile" | tr ':' ' ')) 2>/dev/null
                fieldPrimaryKeysArr=($(sed -n '4p' "$metadataFile" | tr ':' ' ')) 2>/dev/null
                fieldNamesArr=($(sed -n '2p' "$metadataFile" | tr ':' ' ')) 2>/dev/null
                #fieldNamesArr=($(awk -F: 'NR==2 {for (i=1; i<=NF; i++) print i"-"$i }' "$metadataFile"))

                for ((i = 0; i < ${#fieldPrimaryKeysArr[@]}; i++)); do
                    if [[ ${fieldPrimaryKeysArr[$i]} == "primary" ]]; then
                        primaryIndex=$i
                        break
                    fi
                done
                primaryField=$((primaryIndex+1))

                #echo "$primaryField"
                #echo -e "Fields in table $table:\n${fieldNamesArr[@]}"
                echo -e "\nAvailable columns for update:"
                for ((i=0; i<${#fieldNamesArr[@]}; i++))
                do
                    echo "$(($i+1)). ${fieldNamesArr[$i]}"
                done
                #////////////////////////////////////////////////////////////////////////////
                read -p "$(echo -e "${blue}Which column: ${reset}")" col

                if [[ $col -gt 0 ]] && [[ $col -le $numFields ]]; then
                    read -p "$(echo -e "${blue}Where value ([q] to quit): ${reset}")" val
                    read -p "$(echo -e "${blue}To be Updated with : ([q] to quit): ${reset}")" newVal
                
                    if [[ $col -eq $primaryField ]] 
                    then
                        
                        if [[ -z $newVal ]]
                        then
                            echo "Error: Primary field cannot be null."
                            updateTable
                        fi
                        
                        primaryFieldValues=($(awk -F ':' -v field=$primaryField '{print $field}' "$table")) 2>/dev/null
                        uniqueVal=false

                        while ! $uniqueVal 
                        do
                            uniqueVal=true

                            for value in "${primaryFieldValues[@]}"
                            do
                                if [[ "$newVal" == "$value" ]]
                                then
                                    echo "Error: Value for primary field already exists."
                                    read -p "Enter new value for primary field '${fieldNamesArr[$primaryIndex]}': " newVal

                                    uniqueVal=false
                                    break
                                fi
                            done
                            
                        done

                    fi
                else
                    echo -e "${red}Please enter an existing column from 1 to $numFields${reset}"
                fi
                #/////////////////////////////////////////////////////////////////////////////////////////////////////////

                if [[ ${fieldTypesArr[$col-1]} == "int" && ! $newVal =~ ^[0-9]+$ ]] 
                then
                    echo "Error: Value must be an integer for field '${fieldNamesArr[$col-1]}'."
                    
                elif [[ ${fieldTypesArr[$col-1]} == "string" && ! $newVal =~ ^[a-zA-Z0-9_-]+$ ]]
                then
                    echo "Error: Value must be a string for field '${fieldNamesArr[$col-1]}'."
                else

                    if $(cut -d: -f"$col" "$table" | grep -q "^$val$") 
                    then
                        #awk -F: -v col="$col" -v val="$val" '$col == val {print NR, $0}' "$table"
                        sed -i "s/$val/$newVal/g" "$table"
                        
                        echo -e "${green}Rows with '$desiredcol' = '$val' updated successfully${reset}"

                    else
                        echo -e "${red}Value $val not found in column $desiredcol${reset}"

                    fi
                fi
            else
                echo "Error:Metadata file for table '$table' not found."
            fi
        else
            echo "Error: Table '$table' not found."
            updateTable
        fi
    fi
}

updateTable
