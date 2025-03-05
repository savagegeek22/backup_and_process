#! /usr/bin/ksh -x
# jd henderson 8-1-07
# send email notification if # of process exceed X

X=200
ps -ef | wc -l > /tmp/$$.tmp

if (( `cat /tmp/$$.tmp` > $X )) then
        if [[ ! -a /sysadm/.process_watcher_mailsent.flag ]] then
                /usr/bin/mail -s "DELPHI has large process table" root < /tmp/$$.tmp
                touch /sysadm/.process_watcher_mailsent.flag
        fi
else
        if [[ -a /sysadm/.process_watcher_mailsent.flag ]] then
                rm /sysadm/.process_watcher_mailsent.flag
        fi
fi

/bin/rm /tmp/$$.tmp
