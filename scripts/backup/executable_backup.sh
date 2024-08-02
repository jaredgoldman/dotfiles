
#!/bin/bash

# Define the backup location
BACKUP_LOCATION=/mnt/backup

# Define the include list
INCLUDE_FILE=include_list.txt
EXCLUDE_FILE=exclude_list.txt

# Create the backup with includes
borg create --stats --patterns-from $INCLUDE_FILE --exclude-from $EXCLUDE_FILE $BACKUP_LOCATION::my-backup-$(date +%Y-%m-%d)
