#!/bin/sh -x
# backup created 8-1-07
# By jd "savage" henderson
#
datum=`/bin/date +%Y%m%d-%H`

# /usr/bin/mysqladmin --user=root --password=dbpa55

/usr/bin/mysqldump --user=root --password=dbpa55 --lock-all-tables \
      --all-databases > /sysadm/sqlbackup/backup-${datum}.sql

# /usr/bin/mysqladmin --user=root --password=dbpa55

#for file in "$( /usr/bin/find /sysadm/sqlbackup -type f -mtime +2 )"
#do
#  /bin/rm -f $file
#done

exit 0
