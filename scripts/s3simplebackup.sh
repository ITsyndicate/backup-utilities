#!/bin/bash

#AWS installation
#wget -O /tmp/awscli-bundle.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
#unzip /tmp/awscli-bundle.zip -d /tmp
#/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

DATE=`date +%Y-%m-%d`
BACKUPDIR='/etc /ebs/www /ebs/www2' #Directories to be backed up
STORAGEDIR='/ebs/backup' #A directory for TMP backups
DOMAIN='' #Master domain of the client
MYSQLDUMP='/usr/bin/mysqldump'
MYSQLUSER=''
MYSQLPASS=''
AWS='/usr/local/bin/aws'
BUCKET='' #Client bucket at ITsyndicate S3

#aes configuration
export AWS_DEFAULT_REGION='us-west-2'
export AWS_ACCESS_KEY_ID=''
export AWS_SECRET_ACCESS_KEY=''

tar -zcf $STORAGEDIR/${DATE}_$DOMAIN.tar.gz $BACKUPDIR
$MYSQLDUMP --add-drop-database --add-drop-table --disable-keys --all-databases -u$MYSQLUSER\
 -p$MYSQLPASS | gzip > $STORAGEDIR/${DATE}_$DOMAIN.sql.gz

$AWS s3 cp $STORAGEDIR/${DATE}_$DOMAIN.tar.gz s3://$BUCKET/${DATE}_$DOMAIN.tar.gz
$AWS s3 cp $STORAGEDIR/${DATE}_$DOMAIN.sql.gz s3://$BUCKET/${DATE}_$DOMAIN.sql.gz

/usr/bin/find $STORAGEDIR -type f -mtime +3 | /usr/bin/xargs /bin/rm -f >/dev/null 2>&1
