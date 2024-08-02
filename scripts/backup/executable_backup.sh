#!/bin/bash

# Define the backup location
BACKUP_LOCATION=/mnt/backup

# Define the include list
INCLUDE_FILE=/home/jg/scripts/backup/include_list.txt
EXCLUDE_FILE=/home/jg/scripts/backup/exclude_list.txt

# Define the source directory
SOURCE_DIR=/home/jg

# Create the backup with includes
borg create --stats --patterns-from $INCLUDE_FILE --exclude-from $EXCLUDE_FILE $BACKUP_LOCATION::my-backup-$(date +%Y-%m-%d) $SOURCE_DIR

