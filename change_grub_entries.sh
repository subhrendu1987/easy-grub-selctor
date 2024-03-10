#!/bin/bash
GREEN='\033[0;32m'
RED= '\033[0;31m'
##########################################################################
comment_and_add_line() {
    local match_string="$1"
    local replacement="$2"

    # Check if /etc/default/grub file exists
    if [ -f "/etc/default/grub" ]; then
        # Search for the match string in /etc/default/grub
        LINE=$(grep -n "^$match_string" /etc/default/grub)
        if [ -n "$LINE" ]; then
            LINE_NO=$(echo $LINE | awk -F":" '{print $1}')
            LINE_TEXT=$(echo $LINE | awk -F":" '{print $2}')
            NEW_LINES="# $LINE_TEXT\n$replacement"
            echo -e "${RED}- $LINE_TEXT" 
            echo -e "${GREEN}+ $NEW_LINES"
            
        else
            echo "Match not found in /etc/default/grub."
        fi
    else
        echo "/etc/default/grub file not found."
    fi
}
##########################################################################
find_line_number() {
    read -p "Enter the serial number: " SERIAL_NUMBER
    # Search for the line number that matches the provided serial number
    #LINE_NUMBER=$(echo "$GRUB_ENTRIES" | awk -v serial="^$SERIAL_NUMBER\." '$0 ~ serial {print NR}')
    LINE_NUMBER=$(echo "$GRUB_ENTRIES" | grep -n  "^[[:blank:]]*$SERIAL_NUMBER\] "| awk -F":" '{print $1}')
    if [ -n "$LINE_NUMBER" ]; then
        #echo "Line Number: $LINE_NUMBER"
        #echo -n "Selected GRUB Entry:"
        SELECTED_ENTRY=$(echo "$GRUB_ENTRIES" | awk -v line="$LINE_NUMBER" 'NR == line {print}' | awk -F"]" '{print $2}')
    else
        echo "No entry found with serial number: $SERIAL_NUMBER"
    fi
}
##########################################################################
# Function to find the default entry in GRUB
find_default_entry() {
    # Check if the GRUB_DEFAULT variable is set in /etc/default/grub
    if grep -q "^GRUB_DEFAULT=" /etc/default/grub; then
        # Extract the value of GRUB_DEFAULT
        DEFAULT_ENTRY=$(grep "^GRUB_DEFAULT=" /etc/default/grub | cut -d'"' -f2)
        # Parse the output of display_grub_boot_entries to find the serial number of the default entry
        SERIAL_NUMBER=$(echo "$GRUB_ENTRIES" | grep -F "=\"$DEFAULT_ENTRY\"" | awk '{print $1}')
        if [ -n "$SERIAL_NUMBER" ]; then
            echo "[Default GRUB Entry] $SERIAL_NUMBER $DEFAULT_ENTRY"
        else
            echo "[Default GRUB Entry] $DEFAULT_ENTRY (Serial Number: Not Found)"
        fi
    else
        echo "GRUB_DEFAULT is not set in /etc/default/grub."
    fi
}
##########################################################################
# Function to display GRUB entries
display_grub_boot_entries() {
GRUB_ENTRIES=$(awk -F\' '/^menuentry / {printf "%d] GRUB_DEFAULT=\"%s\"\n", ++count, $2}
                  /^submenu / {submenu=$2; subcount=0; ++count}
                  /^\tmenuentry / {printf "%d>%d] GRUB_DEFAULT=\"%s>%s\"\n", count, ++subcount, submenu, $2}' /boot/grub/grub.cfg)

    echo "GRUB Boot Entries:"
    echo "$GRUB_ENTRIES"
}
##########################################################################
# Check if the script is run with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges to access GRUB configuration."
    exit 1
fi
##########################################################################
# Call function to display GRUB entries
display_grub_boot_entries
echo "--------------"
find_default_entry
echo "--------------"
find_line_number
echo "--------------"
# Modify /etc/default/grub file with the suitable entries
if [ -n "$SELECTED_ENTRY" ]; then
    echo "[Selected Entry] "$SELECTED_ENTRY
    comment_and_add_line "GRUB_DEFAULT" "$SELECTED_ENTRY"
    echo "Modify /etc/default/grub file with the suitable entries"
    echo "Update grub with \$ sudo update-grub"
fi

