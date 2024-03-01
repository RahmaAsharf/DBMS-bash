#!/bin/bash

PS3="Please enter number of your choice: "

options=("Create Database" "List Database" "Connect to Database" "Drop Database")


select option in "${options[@]}"
do
case $REPLY in
	1) echo "Creating DB"
        ;;
	2) echo "Listing DBs"
	;;
	3) echo "Connecting to DB"
        ;;
	4) echo "Dropping DB"
        ;;
	*) echo "Invalid option.. Please enter a choice from 1 to 4"
        ;;
esac
done



