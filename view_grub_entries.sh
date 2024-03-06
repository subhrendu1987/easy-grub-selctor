#!/bin/bash
### Example GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 5.15.0-97-generic"
# Function to display GRUB entries
display_grub_boot_entries() {
    echo "GRUB Boot Entries:"
    awk -F\' '/^menuentry / {printf "\t%d. GRUB_DEFAULT=\"%s\"\n", ++count, $2}
              /^submenu / {submenu=$2}
              /^\tmenuentry / {printf "\t\t%d. GRUB_DEFAULT=\"%s>%s\"\n", ++count, submenu, $2}' /boot/grub/grub.cfg
}

# Check if the script is run with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges to access GRUB configuration."
    exit 1
fi

# Call function to display GRUB entries
echo "Modify /etc/default/grub file with the suitable entries" 
display_grub_boot_entries
echo "sudo update-grub" 

