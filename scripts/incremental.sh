#!/bin/bash
# System + MySQL backup script
# Full backup day - Sun (rest of the day do incremental backup)
# ---------------------------------------------------------------------
#Export all locales and en_US time locale with following commands:
export LANG=C
export LC_ALL=C
export LC_TIME="en_US"
### System Setup ###
#Directories to be backuped
DIRS='/home /etc'
#Directory to store backup
MYBACKUP='/backup/mysql'
FULLBACKUP='/backup/full'
INCBACKUP='/backup/incremental'
#Number of days to store full backup e.g 30
FULLBACKUPDAY='30'
#Number of days to store incremental backup e.g 7
INCBACKUPDAY='7'
#Number of days to store mysql backup e.g 3
MYSQLBACKUPDAY='3'
#Current time to add it to the incremental backup names
NOW=`date +"%d-%m-%Y"`
#Incremental log file. Will be used each time to track changes
INCFILE='/root/tar-inc-backup.dat'
#Getting today day
DAY=`date +"%a"`
#Day of the full backup
FULLBACKUPDAYWEEK='Sun'

### MySQL Setup ###
#Mysql user
MUSER="root"
#Mysql pass
MPASS="pass"
#Mysql server host
MHOST="localhost"
#Setting up full mysql path
MYSQL=`which mysql`
#Setting up full mysqldump path
MYSQLDUMP=`which mysqldump`
#Setting up full gzip path
GZIP=`which gzip`

### Start Backup for file system ###
#Checking if directory not exist. Creating it if not
if [ ! -d "$FULLBACKUP" ]; then
	mkdir -p $FULLBACKUP
fi
if [ ! -d "$INCBACKUP" ]; then
        mkdir -p $INCBACKUP
fi
if [ ! -d "$MYBACKUP" ]; then
        mkdir -p $MYBACKUP
fi

### See if we want to make a full backup ###
#Checking if today is the day to make a full backup
if [ "$DAY" == "$FULLBACKUPDAYWEEK" ]; then
  #Name our backup file
  FILE="fs-full-$NOW.tar.gz"
  #Creating archive of or dirs and save it to the backup folder
  tar -zcvf $FULLBACKUP/$FILE $DIRS
#In all other cases making incremental backup
else
  #Setting variable for incremental backup naming with date, time, seconds
  i=`date +"%Hh%Mm%Ss"`
  #Naming our file
  FILE="fs-i-$NOW-$i.tar.gz"
  #Creating archive of or dirs and save it to the backup folder but checking log of incremental backup
  tar -g $INCFILE -zcvf $INCBACKUP/$FILE $DIRS
fi

### Start MySQL Backup ###
# Get all databases name
DBS=`$MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases'`
for db in $DBS
do
 #Naming our backup
 FILE=$MYBACKUP/mysql-$db.$NOW-`date +"%T"`.gz
 #Creating full mysql backup
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done

#Removing files older then days in full backup directory
FIND=`which find`
$FIND $FULLBACKUP -type f -mtime +$FULLBACKUPDAY | /usr/bin/xargs /bin/rm -f >/dev/null 2>&1
$FIND $INCBACKUP -type f -mtime +$INCBACKUPDAY | /usr/bin/xargs /bin/rm -f >/dev/null 2>&1
$FIND $MYBACKUP -type f -mtime +$MYSQLBACKUPDAY | /usr/bin/xargs /bin/rm -f >/dev/null 2>&1
