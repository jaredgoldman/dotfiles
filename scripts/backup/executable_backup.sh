#!/bin/bash

# Define the backup location
BACKUP_LOCATION=/mnt/backup

# Define the include and exclude files
INCLUDE_FILE=/home/jg/scripts/backup/include_list.txt
EXCLUDE_FILE=/home/jg/scripts/backup/exclude_list.txt

# Define the source directory
SOURCE_DIR=/home/jg

# Read the Borg passphrase from a file
export BORG_PASSPHRASE=$(cat /home/jg/scripts/backup/passphrase.txt)

# Log file for debugging
LOG_FILE=/home/jg/scripts/backup/backup.log

# Create the backup with includes and log the output
{
    echo "Starting backup at $(date)"
    borg create --stats --patterns-from $INCLUDE_FILE --exclude-from $EXCLUDE_FILE $BACKUP_LOCATION::my-backup-$(date +%Y-%m-%d) $SOURCE_DIR
    echo "Backup finished at $(date)"
} >> $LOG_FILE 2>&1

# Unset the passphrase after backup
unset BORG_PASSPHRASE

