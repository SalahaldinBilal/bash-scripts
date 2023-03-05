#!/bin/bash

# Print Colors
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)
POWDER_BLUE=$(tput setaf 153)
LIME_YELLOW=$(tput setaf 190)
BLINK=$(tput blink)

# Getting device information
IFS=$'\n'
DEVICE=($(hostnamectl | awk -F': ' '{for(i=1;i<=NF;i++){print $i}}'))
OS=${DEVICE[13]}
KERNAL=${DEVICE[15]}
USER=$(whoami)

# Answer sperator
SEP="${BLINK}${LIME_YELLOW}------------------------------------------${NORMAL}"

# App state
EXIT=false
INNER_EXIT=false
REDO_COMMAND=false
IS_UNKNOWN_INPUT=false

# To convert arguments to choices
declare -A COMMAND_LINE_TO_CHOICE=( ["p"]=1 ["r"]=2 ["h"]=3 ["a"]=4 )

get_apache_version () {
    OLD_IFS=$IFS
    IFS=$'\n'
    TEMP_OUTPUT=($(apache2 -v | awk -F': |\\(|/' '{for(i=1;i<=NF;i++){print $i}}'))
    IFS=$OLD_IFS
    echo ${TEMP_OUTPUT[2]}
}

# Function to handle user choice
handle_choice () {
    echo $SEP
    printf "\n"
    
    case $1 in
        1) ps -u $USER;;
        2) free -h;;
        3) df -h;;
        4)
            if [[ $(which apache2) ]]; then
                echo "Apache version: ${LIME_YELLOW}$(get_apache_version)${NORMAL}"
            else
                echo "Apache is not installed"
            fi
        ;;
        5) 
            echo "Existing ..."
            EXIT=true
        ;;
        *)
            IS_UNKNOWN_INPUT=true
            echo "Unknown Input"
        ;;
    esac
    
    printf "\n"
    echo $SEP
}

if [[ $# -gt 0 ]]; then
    # Run commands provided by user
    for COMMAND in "$@"
    do
        handle_choice ${COMMAND_LINE_TO_CHOICE[$COMMAND]}
    done
else
    # Printing welcome message
    printf 'Welcome %s\nCurrent date: %(%Y-%m-%d)T\nRunning On: %s\nKernal: %s\n\n' "${BLINK}$USER${NORMAL}" -1 "${POWDER_BLUE}$OS${NORMAL}" "${POWDER_BLUE}$KERNAL${NORMAL}"
    FIRST_OPTIONS="
    1) List the running process.
    2) Check the memory status and free memory in the RAM.
    3) Check the hard disk status and free memory in the HDD.
    4) Check if apache is installed.
    5) Exit.
    
        Your Input: "
    
    SECOND_OPTIONS="
    1) Back to main view.
    2) Update view.
    3) Exit.
    
        Your Input: "

    IFS=$''

    # App loop
    until [ $EXIT = true ]; do
        if [[ $REDO_COMMAND = false ]]; then
            read -p $FIRST_OPTIONS CHOICE
        fi
        
        INNER_EXIT=false
        REDO_COMMAND=false
        IS_UNKNOWN_INPUT=false
        
        handle_choice $CHOICE
        
        if [[ $IS_UNKNOWN_INPUT = false ]]; then
            until [ $INNER_EXIT = true ] || [ $EXIT == true ]; do
                read -p $SECOND_OPTIONS CHOICE2
                printf "\n"
                
                case $CHOICE2 in
                    1)
                        INNER_EXIT=true
                    ;;
                    2)
                        INNER_EXIT=true
                        REDO_COMMAND=true
                    ;;
                    3)
                        EXIT=true
                    ;;
                    *)
                        echo "Unknown Input"
                    ;;
                esac
            done
        fi
    done
fi
