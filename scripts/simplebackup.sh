#!/bin/bash

DATE=`date +%Y-%m-%d`
BACKUPDIR='/bar/www/domain.com'
STORAGEDIR='/backup'
DOMAIN='domain.com'
MYSQLDUMP='/usr/bin/mysqldump'
MYSQLPASS='pass'
MYSQLUSER='root'

tar -zcf $STORAGEDIR/${DATE}_$DOMAIN.tar.gz $BACKUPDIR
$MYSQLDUMP --add-drop-database --add-drop-table --disable-keys --all-databases -u$MYSQLUSER\
 -p$MYSQLPASS | gzip > $STORAGEDIR/${DATE}_$DOMAIN.sql.gz
chown -R user.user $STORAGEDIR
rsync -avz -e "ssh -i /var/nginx/www/.ssh/id_rsa" /var/backups/ username@backup.domain.com:/home/backup/
/usr/bin/find $STORAGEDIR -type f -mtime +7 | /usr/bin/xargs /bin/rm -f >/dev/null 2>&1
