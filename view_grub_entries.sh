#!/bin/bash

# Function to find the default entry in GRUB
find_default_entry() {
    # Check if the GRUB_DEFAULT variable is set in /etc/default/grub
    if grep -q "^GRUB_DEFAULT=" /etc/default/grub; then
        # Extract the value of GRUB_DEFAULT
        DEFAULT_ENTRY=$(grep "^GRUB_DEFAULT=" /etc/default/grub | cut -d'"' -f2)
        # Parse the output of display_grub_boot_entries to find the serial number of the default entry
        SERIAL_NUMBER=$(echo "$GRUB_ENTRIES" | grep -F "=\"$DEFAULT_ENTRY\"" | awk '{print $1}')
        if [ -n "$SERIAL_NUMBER" ]; then
            echo "[Note] Default GRUB Entry: $DEFAULT_ENTRY (Matching Serial Number(s): $SERIAL_NUMBER)"
        else
            echo "[Note] Default GRUB Entry: $DEFAULT_ENTRY (Serial Number: Not Found)"
        fi
    else
        echo "GRUB_DEFAULT is not set in /etc/default/grub."
    fi
}

# Function to display GRUB entries
display_grub_boot_entries() {
GRUB_ENTRIES=$(awk -F\' '/^menuentry / {printf "\t%d. GRUB_DEFAULT=\"%s\"\n", ++count, $2}
                  /^submenu / {submenu=$2; subcount=0; ++count}
                  /^\tmenuentry / {printf "\t\t%d>%d. GRUB_DEFAULT=\"%s>%s\"\n", count, ++subcount, submenu, $2}' /boot/grub/grub.cfg)

    echo "GRUB Boot Entries:"
    echo "$GRUB_ENTRIES"
}

# Check if the script is run with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges to access GRUB configuration."
    exit 1
fi

# Call function to display GRUB entries
display_grub_boot_entries

echo "--------------"
echo "[Note] Modify /etc/default/grub file with the suitable entries"
find_default_entry
echo "Update grub with sudo update-grub"
