#!bin/sh
dropTable(){
    ../../listTables.sh
    read -p "$(echo -e "${red}Which tableToUpdate do you want to drop? [q] to quit: ${reset}")" tableToDrop

    
}