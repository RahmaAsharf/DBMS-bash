#!/bin/bash

function quit() {
    if [ "$1" == ':q' ] || [ "$1" == ':Q' ]
    then
        clear
        echo -e "${orange}Quitting!${reset}"
        $2  
    fi
}
#-----------------------------------------LIST TABLES--------------------------------------
listTables() {

    tablesExist=0
    echo -e "${blue}\nList of Tables:${reset}"
    echo -e "${blue}------------------------------------${reset}"

    for table in *
    do
        if [ -f "$table" ]
        then
            echo "$(basename "$table")"
            tablesExist=1
        fi
    done

    if [ $tablesExist -eq 0 ] 
    then
        echo -e "${orange}No tables found.${reset}"
    fi
    echo -e "${blue}------------------------------------${reset}\n"
}
#-------------------------------------------------------------------------------------------
#-----------------------------------------CREATE TABLE--------------------------------------
tableRegex='^[a-zA-Z_][a-zA-Z0-9_]*$'
createTable() {

    echo -e "${yellow}NOTE: (no spaces, cannot begin with a number, no special characters)\n${reset}"
    read -p "Enter the table name or ':q' to quit: " tableName
    quit "$tableName" "tableMenu"

    if [ -f "$tableName" ] #table exists?
    then
        echo -e "\n${red}Error: Table with the name '$tableName' already exists.\n${reset}"
        return
    fi

    if [[ ! "$tableName" =~ $tableRegex ]] #table matches regex?
    then
        echo -e "\n${red}Error: Invalid table name. Please follow the specified rules at the beginning.\n${reset}"
        return
    fi
   
    while true 
    do
    read -p "Enter the number of fields/columns or ':q' to quit: " numFields
    quit "$numFields" "tableMenu"
    if [[ $numFields =~ ^[1-9][0-9]*$ ]]
    then
        break 
    else
        echo -e "${red}Invalid input. Please enter a valid number greater than 0.${reset}"
    fi
    done
    # initialize arrays to store field information
    fieldNames=()
    fieldTypes=()
    fieldPrimaryKeys=()
    primaryKeyIsSet=0

    for ((i = 1; i <= numFields; i++))    # for each column
    do
        echo "------------------------------------"
        echo "Field $i:"
        while true
        do
            read -p "Enter the field name: " fieldName
            quit "$fieldName" "tableMenu"

            if [[ "${fieldNames[@]}" =~ "$fieldName" ]]
            then
                echo -e "${red}Error: Field name '$fieldName' already exists. Please enter a unique field name.${reset}"
            else
                fieldNames+=("$fieldName")
                break
            fi
        done

        if [[ ! "$fieldName" =~ $tableRegex ]]
        then
            echo -e "${red}Error: Invalid field name. Please follow the specified rules.${reset}"
            echo -e "------------------------------------\n"
            return
        fi

       if [ $primaryKeyIsSet -eq 0 ]   
       then
            while true     # ask if it's a primary key
            do
                PS3="Is it a primary key? "
                select isPrimaryOption in "yes" "no" "quit"
                do
                case $REPLY in
                1) primary="primary"; primaryKeyIsSet=1
                break ;;
                2) primary="notprimary" 
                 break ;;
                3) echo -e "${orange}Quitting!${reset}"
                tableMenu
                ;;
                *) echo -e "${red}Invalid option.. Please enter 1,2 or 3${reset}" ;;
                esac
                done

               [ -n "$isPrimaryOption" ] && break
            done

               fieldPrimaryKeys+=("$primary")
               echo " "
        
        else 
         fieldPrimaryKeys+=("notprimary")
        fi 

         while true    # ask if it's a String or int
         do
            PS3="Select field type : "
            select fieldOption in "string" "int" "quit"
            do
            case $REPLY in
            1) fieldType="string"
            break ;;
            2) fieldType="int"
            break ;;
            3) echo -e "${orange}Quitting!${reset}"
               tableMenu  ;;
            *) echo -e "${red}Invalid option.. Please enter 1,2 or 3${reset}" ;;
            esac
            done

            [ -n "$fieldOption" ] && break

         done

        fieldTypes+=("$fieldType")
        echo " "
      done

        if [ "$primaryKeyIsSet" -eq 0 ]
        then
            echo "------------------------------------"
            echo -e "${yellow}No primary key was set. Please choose one field as it is mandatory.${reset}"
            PS3="Select a field: "
            select primaryField in "${fieldNames[@]}"
            do
                if [ -n "$primaryField" ]
                then
                    index=0
                    for field in "${fieldNames[@]}"
                    do
                        if [ "$field" = "$primaryField" ]
                        then
                            fieldPrimaryKeys[$index]="primary"
                            echo -e "${green}Field '$primaryField' is now set as primary key.${reset}"
                            break
                        fi
                        index=$((index+1))
                    done
                    break
                else
                    echo -e "${red}Invalid option.. Please enter a number from 1 to $numFields${reset}"
                fi
            done
        fi
    ###########################################
    # create a file for data
    touch "$tableName"
    chmod -R 777 $tableName
    # create a metadata file
    echo  "$numFields" > ".$tableName-metadata" 
    echo "${fieldNames[*]}" | tr ' ' ':' >> ".$tableName-metadata" 
    echo "${fieldTypes[*]}" | tr ' ' ':' >> ".$tableName-metadata"
    echo "${fieldPrimaryKeys[*]}" | tr ' ' ':' >> ".$tableName-metadata"
    echo -e "${green}Table $tableName created successfully!${reset}"
    echo "------------------------------------"
}
#-------------------------------------------------------------------------------------------
#-----------------------------------------INSERT TABLE--------------------------------------
insertIntoTable() {
   
    listTables
    echo -e "${yellow}NOTE: to quit at any point enter ':q'\n${reset}"
    echo -e "${orange}Which table do you want to insert data into? ${reset}"
    read tableToInsert
    quit "$tableToInsert" "tableMenu"

    # check if the table name is in DB
    if [ ! -f "$tableToInsert" ]
    then
        echo -e "${red}Error: Table with the name '$tableToInsert' does not exist in your DB.\n${reset}"
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
            quit "$fieldValue" "tableMenu"

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
                                quit "$fieldValue" "tableMenu"
                            
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
                elif [[ ${fieldTypesArr[$i]} == "string" && ! $fieldValue =~ ^[^:]+$ ]]
                then
                    echo -e "${red}Error: Value must be a string for field '${fieldNamesArr[$i]}'and it can't have ':'.${reset}"
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
#-------------------------------------------------------------------------------------------
#-----------------------------------------UPDATE TABLE--------------------------------------
updateTable() {
    echo -e "${orange}\n___________________ In Update table ___________________${reset}"
    listTables
    echo -e "${yellow}NOTE: to quit at any point enter ':q'\n${reset}"

    while true
    do
        read -p "$(echo -e "${orange}Which table do you want to update? ${reset}")" tableToUpdate

        if [ "$tableToUpdate" == ':q' ] || [ "$tableToUpdate" == ':Q' ]
        then
            echo -e "${orange}You pressed quit...Quitting!${reset}"
            tableMenu
        elif [ -f "$tableToUpdate" ] && [ -f ".$tableToUpdate-metadata" ]
        then
            # variables initialization
            metadata=".$tableToUpdate-metadata"
            numFields=$(head -n 1 "$metadata" 2>/dev/null)
            fields=($(sed -n '2p' "$metadata" | tr ':' ' ' 2>/dev/null))
            fieldTypesArr=($(sed -n '3p' "$metadata" | tr ':' ' ' 2>/dev/null))
            fieldPrimaryKeysArr=($(sed -n '4p' "$metadata" | tr ':' ' ' 2>/dev/null))
            
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
                read -p "$(echo -e "${blue}Which column you want to update by (select by number): ${reset}")" colToUpdate
                quit "$colToUpdate" "updateTable"
                
                # Checking if the colToUpdate num is available
                if [[ $colToUpdate -gt 0 ]] && [[ $colToUpdate -le $numFields ]]
                then
                    while true
                    do
                        read -p "$(echo -e "${blue}Where value: ${reset}")" val
                        quit "$val" "updateTable"

                        if $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$")
                        then
                            while true
                            do
                                read -p "$(echo -e "${blue}To be Updated with: ${reset}")" newVal
                                quit "$newVal" "updateTable"

                                # Checking if colToUpdate is PK
                                if [[ $colToUpdate -eq $primaryField ]]
                                then
                                    # Checking if it is null
                                    if [[ -z $newVal ]]
                                    then
                                        echo -e "${red}Error: Primary field cannot be null${reset}"
                                        continue  # Go back to the previous loop
                                    # Checking if the newVal is unique
                                    elif $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$newVal$")
                                    then
                                        echo -e "${red}Error: '$newVal' already exists, Primary field must be unique${reset}"
                                        continue  # Go back to the previous loop
                                    else
                                        break
                                    fi
                                else
                                    break
                                fi
                            done

                            if [[ ${fieldTypesArr[$((colToUpdate - 1))]} == "int" && ! $newVal =~ ^[0-9]+$ ]]
                            then
                                echo -e "${red}Error: Value must be an integer for field '${fields[$((colToUpdate - 1))]}'.${reset}"
                                    
                            elif [[ ${fieldTypesArr[$((colToUpdate - 1))]} == "string" && ! $newVal =~ ^[^:]+$ ]]
                            then
                                echo -e "${red}Error: Value can't have ':' for field '${fields[$((colToUpdate - 1))]}'. ${reset}"
                      
                            # If everything is valid, update the table
                            elif $(cut -d: -f"$colToUpdate" "$tableToUpdate" | grep -q "^$val$")
                            then
                                sed -i "s/$val/$newVal/g" "$tableToUpdate"
                                clear
                                echo -e "${green}Rows with '${fields[$colToUpdate - 1]}' = '$val' updated successfully${reset}"
                                
                                updateTable
                            else
                                echo -e "${red}Value $val not found in column $colToUpdate${reset}"
                            fi
                        else
                            echo -e "${red}'$val' is not a valid value in column $colToUpdate${reset}"
                        fi
                    done
                else
                    echo -e "${red}Please enter an existing column from 1 to $numFields${reset}"
                fi
            done
        else
            echo -e "${red}Error: Table '$tableToUpdate' not found.${reset}"
        fi
    done
}

#-------------------------------------------------------------------------------------------
#-----------------------------------------SELECT TABLE--------------------------------------
# to select all data from the table
select_all() {

    listTables
    echo -e "${orange}Which table do you want to select from? ([:q] to quit)${reset}"
    read table
    quit "$table" "selectFromTable"

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
        printf "${yellow}%-15s${reset}" "${fields[$i]}"  
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

    listTables
    echo -e "${orange}Which table do you want to select from? ([:q] to quit)${reset}"
    read table
    quit "$table" "selectFromTable"
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

    echo -e "${orange}Enter column numbers separated by spaces or ([:q] to quit)${reset}"
    read cols
    quit "$cols" "selectFromTable"

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
        printf "${yellow}%-16s${reset}" "${fields[$index]}"
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
    listTables
    echo -e "${orange}Which table do you want to select from? ([:q] to quit) ${reset}"
    read table
    quit "$table" "selectFromTable"
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

    # Displays available columns 
    echo -e "\nAvailable columns for selection:"
    for ((i=0; i<${#fields[@]}; i++)); do
        echo "$(($i+1)). ${fields[$i]}"
    done

    numFields=$(head -n 1 "$metadata" 2>/dev/null)

    read -p $'\n\e[1;34mEnter number of column: \e[0m' col

    if [[ $col -gt 0 && $col -le $numFields ]]
    then
        read -p $'\n\e[1;34mWhich value: \e[0m' val

        if $(cut -d: -f"$col" "$table" | grep -q "^$val$")
        then
            echo -e "${blue}\n*********************** Table $table *************************${reset}"
            echo -e "${blue}************************************************************${reset}"
            echo -e "${green}Value '$val' found in rows: ${reset}"
            for ((i=0; i<${#fields[@]}; i++))
            do
                printf "${yellow}%-15s${reset}" "${fields[$i]}"  
            done
            echo -e "${blue}\n************************************************************${reset}"
            awk -F ':' -v col="$col" -v val="$val" '{ if ($col == val) { for (i=1; i<=NF; i++) printf "%-15s", $i; printf "\n"} }' "$table"
            echo -e "${blue}************************************************************${reset}"

        else
            echo -e "${red}Value $val not found in column $col${reset}"
        fi
    else 
        echo -e "${red}Please enter an existing column from 1 to $numFields${reset}"
    fi
}

# menu to select from
selectFromTable() {
    PS3="Please select an option: "
    options=("Select all" "Select by column (projection)" "Select rows (selection) with condition" "Exit Select Menu")

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
            ;;
            *) echo -e "${red}Invalid option. Please select a number from 1 to 4.${reset}" ;;
        esac
    done
}
#-------------------------------------------------------------------------------------------
#-----------------------------------------DELETE FROM TABLE--------------------------------------
deleteFromTable() {
    echo -e "${orange}___________________ In Delete from table ___________________${reset}"
    PS3="Enter option: "
    listTables
    read -p "$(echo -e "${orange}Which table do you want to delete from? [:q] to quit: ${reset}")" table
    quit "$table" "tableMenu"

    if [ -f "$table" ]; then
        select option in "Delete all records" "Delete specific row" "Back to Table Menu"; do
            case $REPLY in
                1)
                    echo -n > "$table"
                    clear
                    echo -e "${green}Table $table is now empty!\n${reset}"
                    ;;
                2)
                    deleteRow "$table"
                    ;;
                3)
                    echo "Exiting to Table Menu"
                    tableMenu
                    ;;
                *)
                    echo "Invalid input."
                    ;;
            esac
            tableMenu
            break
        done
    else
        echo -e "${red}Table '$table' does not exist.${reset}"
        deleteFromTable
    fi
}
deleteRow() {
    local table="$1"
    local metadata_file=".$table-metadata"
    local data_file="$table"
    numFields=$(head -n 1 "$metadata_file") 2>/dev/null
    fieldNamesArr=($(awk -F: 'NR==2 {for (i=1; i<=NF; i++) print i"-"$i }' "$metadata_file"))
    fields=($(sed -n '2p' "$metadata_file" | tr ':' ' ' 2>/dev/null))

    echo -e "\nColumns in table $tableToUpdate:"
    for ((i = 0; i < ${#fields[@]}; i++))
    do
        echo "$(($i + 1)). ${fields[$i]}"
    done
    
    echo -e "${yellow}NOTE: to quit at any point enter ':q'\n${reset}"
    read -p "$(echo -e "${blue}Enter number of column : ${reset}")" col
    quit "$col" "deleteFromTable"

    if [[ $col -gt 0 ]] && [[ $col -le $numFields ]]
    then
        desiredcol=$(echo "${fieldNamesArr[$col-1]}" | awk -F- '{print $2}')
        read -p "$(echo -e "${blue}Where value : ${reset}")" val
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
#-------------------------------------------------------------------------------------------
#-----------------------------------------DROP TABLE--------------------------------------
dropTable() {
    listTables
    while true 
    do
        echo -e "${orange}Which table do you want to drop? [:q] to quit: ${reset}"
        read tableToDrop
        quit "$tableToDrop" tableMenu
     
        if [ -f "$tableToDrop" ] && [ -f ".$tableToDrop-metadata" ]
        then
            while true
            do
                echo -e "${red}Are you sure you want to drop $tableToDrop? This cannot be undone. [y/N]: ${reset}"
                read confirmation
                case "$confirmation" in
                    y|Y)
                        rm -f "$tableToDrop" ".$tableToDrop-metadata"
                        echo -e "${green}Table $tableToDrop is dropped successfully.${reset}\n"
                        return
                        ;;
                    n|N)
                        echo -e "${green}Table drop cancelled.${reset}\n"
                        return
                        ;;
                    *)
                        echo -e "${red}Please answer y or n.${reset}\n"
                        ;;
                esac
            done
        else
            echo -e "${red}Invalid table name, please choose a valid one.${reset}\n"
        fi
    done
}
#-------------------------------------------------------------------------------------------


# main menu for tables inside connected DB
tableMenu() {
    PS3="Please enter the number of your choice: "
    tableOptions=("List Tables" "Create Table" "Insert in table" "Drop table" "Select from table" "Delete from table" "Update from table" "Exit Table Menu" "Exit program")

    echo -e "${orange}___________  In $connectdb DB ____________${reset}"
    echo -e "${blue}------------------------------------${reset}"
    echo -e "${blue}            Table Menu              ${reset}"
    echo -e "${blue}------------------------------------${reset}"

    select tableOption in "${tableOptions[@]}"
    do
        case $REPLY in

        1) clear
           listTables
           tableMenu
         ;;
        2) clear
           createTable
           tableMenu
        ;;
        3)  clear 
            insertIntoTable
            tableMenu
        ;;
        4) clear
            dropTable
            tableMenu
        ;;
        5) clear
           selectFromTable
           echo "selectFromTable" 
        ;;
        6)  clear
            deleteFromTable
            tableMenu
        ;;
        7) clear
            updateTable
            tableMenu
        ;;
        8) echo -e "${orange}Exiting Table Menu...\n${reset}"
           cd ../../
           main
        ;;
        9) echo -e "${yellow}Exiting see you soon!...${reset}"
           exit 0
        ;; 
        *) echo -e "${red}Invalid option.. Please enter a choice from 1 to 9${reset}" 
        ;;
        esac
    done
}

# calling the menu function
tableMenu
