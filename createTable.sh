#!/bin/bash

tableRegex='^[a-zA-Z_][a-zA-Z0-9_]{1,62}$' 

createTable() {
    # Ask user for table name
    echo "Note: (no spaces, 2-63 characters, cannot begin with a number, no special characters)"
    read -p "Enter the table name : " tableName

    # Check if the table name already exists
    if [ -f "$tableName" ]
    then
        echo "Error: Table with the name '$tableName' already exists."
        return
    fi

    # Check regex for table name
    if [[ ! "$tableName" =~ $tableRegex ]]
    then
        echo "Error: Invalid table name. Please follow the specified rules."
        echo "------------------------------------"
        return
    fi
   
    # Ask user for the number of fields/columns
    read -p "Enter the number of fields/columns: " numFields
   
    # Initialize arrays to store field information
    fieldNames=()
    fieldTypes=()
    #fieldNullability=()
    fieldPrimaryKeys=()
    primaryKeyIsSet=0

    # For each column
    for ((i = 1; i <= numFields; i++))
    do
        echo "------------------------------------"
        echo "Field $i:"

        # Ask for field name
        read -p "Enter the field name: " fieldName
        
        # Check regex for field name
        if [[ ! "$fieldName" =~ $tableRegex ]]
        then
            echo "Error: Invalid field name. Please follow the specified rules."
            echo "------------------------------------"
            return
        fi

        fieldNames+=("$fieldName")
        echo " "

       if [ $primaryKeyIsSet -eq 0 ]   
       then
            # Ask if it's a primary key
            while true
            do
                PS3="Is it a primary key? "
                #read -p "Is it a primary key? (yes/no): " isPrimaryKey
                select isPrimaryOption in "yes" "no"
                do
                case $REPLY in
                1) primary="primary"; primaryKeyIsSet=1
                break ;;
                2) primary="notprimary" 
                 break ;;
                *) echo "Invalid option.. Please enter 1 or 2" ;;
                esac
                done

               [ -n "$isPrimaryOption" ] && break
            done

               fieldPrimaryKeys+=("$primary")
               echo " "
        
        else 

         fieldPrimaryKeys+=("notprimary")

        fi 

      # Ask if it's a String or int
         while true
         do
            PS3="Select field type : "
            select fieldOption in "string" "int"; 
            do
            case $REPLY in
            1) fieldType="string"
            break ;;
            2) fieldType="int"
            break ;;
            *) echo "Invalid option.. Please enter 1 or 2" ;;
            esac
            done

            [ -n "$fieldOption" ] && break

         done

        fieldTypes+=("$fieldType")
        echo " "

    #   # Ask null or not null
    #     while true 
    #     do
    #         PS3="Is it nullable? : "
    #         select isNullable in "yes" "no"
    #         do
    #         case $REPLY in
    #         1) fieldNullability+=("nullable")
    #         break ;;
    #         2) fieldNullability+=("notnullable")
    #         break ;;
    #         *) echo "Invalid option.. Please enter 1 or 2"
    #          ;;
    #         esac
    #            break
    #         done
    #      [ -n "$isNullable" ] && break

    #     done

    #     echo " "

      done
    ##########################################
        if [ "$primaryKeyIsSet" -eq 0 ]
        then
            echo "------------------------------------"
            echo "No primary key was set. Please choose one field as it is mandatory."
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
                            echo "Field '$primaryField' is now set as mandatory (primary key)."
                            break
                        fi
                        index=$((index+1))
                    done
                    break
                else
                    echo "Invalid option.. Please enter a number from 1 to $numFields"
                fi
            done
        fi

    ###########################################

    # Create a file for data
    touch "$tableName"
    `chmod -R 777 $tableName`

    # Create a metadata file
    echo  $numFields > ".$tableName-metadata" 
    echo "${fieldNames[*]}" | tr ' ' ':' >> ".$tableName-metadata" 
    echo "${fieldTypes[*]}" | tr ' ' ':' >> ".$tableName-metadata"
    #echo "${fieldNullability[*]}" | tr ' ' ':' >> ".$tableName-metadata"
    echo "${fieldPrimaryKeys[*]}" | tr ' ' ':' >> ".$tableName-metadata"

    echo "Table $tableName created successfully!"
    echo "------------------------------------"

    
}

createTable