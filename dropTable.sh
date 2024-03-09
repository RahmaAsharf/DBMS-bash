#!/bin/sh
# blue='\033[1;34m'
# red='\033[1;31m'
# green='\033[1;32m'
# reset='\033[0m'

# dropTable() {
#     ../../listTables.sh
#     while true; do
#         printf "${red}Which table do you want to drop? [q] to quit: ${reset}"
#         read tableToDrop

#         if [ "$tableToDrop" = 'q' ] || [ "$tableToDrop" = 'Q' ]; then
#             printf "${yellow}You pressed quit.${reset}\n"
#             ../../tables.sh 
#             break # Exit the function
#         elif [ -f "$tableToDrop" ] && [ -f ".$tableToDrop-metadata" ]; then
#             printf "${red}Are you sure you want to drop $tableToDrop? This cannot be undone. [y/N]: ${reset}"
#             read confirmation
#             case "$confirmation" in
#                 y|Y)
#                     rm -f "$tableToDrop" ".$tableToDrop-metadata"
#                     printf "${green}Table $tableToDrop is dropped successfully.${reset}\n"
#                     return ;;
#                 n|N|*)
#                     printf "${green}Table drop cancelled.${reset}\n"
#                     return ;;
#             esac
#         else
#             while true; do
#                 printf "${red}Invalid table name, please choose a valid one: ${reset}"
#                 read tableToDrop
#                 if [ -f "$tableToDrop" ] && [ -f ".$tableToDrop-metadata" ]; then
#                     break
#                 elif [ "$tableToDrop" = 'q' ] || [ "$tableToDrop" = 'Q' ]; then
#                     printf "${yellow}You pressed quit.${reset}\n"
#                     ../../tables.sh 
#                     return # Exit the function
#                 fi
#             done
#         fi
#     done
# }

# dropTable

#/////////////////////////////////////////////////////////

blue='\033[1;34m'
red='\033[1;31m'
green='\033[1;32m'
reset='\033[0m'

dropTable() {
    ../../listTables.sh
    while true; do
        printf "${red}Which table do you want to drop? [q] to quit: ${reset}"
        read tableToDrop

        if [ "$tableToDrop" = 'q' ] || [ "$tableToDrop" = 'Q' ]; then
            printf "${yellow}You pressed quit.${reset}\n"
            ../../tables.sh
            break # Assuming you want to return to the previous menu or exit the function
        elif [ -f "$tableToDrop" ] && [ -f ".$tableToDrop-metadata" ]; then
            while true; do
                printf "${red}Are you sure you want to drop $tableToDrop? This cannot be undone. [y/N]: ${reset}"
                read confirmation
                case "$confirmation" in
                    y|Y)
                        rm -f "$tableToDrop" ".$tableToDrop-metadata"
                        printf "${green}Table $tableToDrop is dropped successfully.${reset}\n"
                        return
                        ;;
                    n|N)
                        printf "${green}Table drop cancelled.${reset}\n"
                        return
                        ;;
                    *)
                        printf "${red}Please answer y or n.${reset}\n"
                        ;;
                esac
            done
        else
            printf "${red}Invalid table name, please choose a valid one.${reset}\n"
        fi
    done
}

dropTable
