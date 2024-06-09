# How to use?
## Execute
	```
	sudo sh change_grub_entries.sh 
 	```
	Copy the corresponding entry (except the serial number) and modify `/etc/default/grub` file with the copied string. After modification
	```
	sudo update-grub
	```
