**Team:**
- Doaa Gamal
- Rahma Ashraf 

# Bash Shell Script Database Management System (DBMS)

## Overview

The Bash Shell Script DBMS project is a Command Line Interface (CLI) menu-based application designed to enable users to store and retrieve data from the hard disk. The project has two main menus: the Main Menu and the Database Menu, providing various functionalities for database and table management.

## Main Menu

![WhatsApp Image 2024-03-10 at 10 47 46 PM](https://github.com/RahmaAsharf/DBMS-bash/assets/94852102/5b118fb1-0782-46e9-8736-dda762616872)

1. **Create Database**
   - Create a new database.
   - Validate the database name for special characters, spaces, and numeric starting characters.
   - Handle errors for existing database names.

2. **List Databases**
   - Display a list of existing databases.

3. **Connect To Database**
   - Connect to a specific database.
   - Navigate to the Database Menu.

4. **Drop Database**
   - Remove a database.
   - Validate the database name and handle errors.

5. **Exit Program**
   - Terminate the script.

## Database Table Menu

![image](https://github.com/RahmaAsharf/DBMS-bash/assets/94852102/ca847ab3-2136-45cf-9449-7d8a715e5cea)

1. **Create Table**
   - Create a new table within the connected database.
   - Validate table name and column specifications.
   - Handle primary keys and data types.

2. **List Tables**
   - Display a list of tables in the connected database.

3. **Drop Table**
   - Remove a table from the connected database.

4. **Insert into Table**
   - Insert data into a table based on metadata specifications.
   - Validate data against metadata rules.

5. **Select From Table**
   - Retrieve data from a table based on various criteria.
   - Provide options for selecting all, selecting by column, or projecting a specific column.

6. **Delete From Table**
   - Remove data from a table based on specified conditions.

7. **Update Table**
   - Update existing data in a table based on specified conditions.

## Project Structure

- **DB Directory**
  - Contains all project data.
- **Table File**
  - Represents a table, storing data and metadata.
  - Metadata can be stored at the beginning of the file or in a separate file (TABLE_NAME-metadata).

## Steps to run 
  ```
     git clone git@github.com:RahmaAsharf/DBMS-bash.git
     cd DBMS-bash
     ./main-menu.sh
   ```
- Follow the on-screen prompts to interact with the menus.


> Cloud PD'44 ITI