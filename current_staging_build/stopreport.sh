#!/bin/bash
export PATH=/usr/bin
PIDFILE=/var/run/ublip_db/stopreport.pid
ps_options="p"
if test -f $PIDFILE
then
  PID=`/bin/cat $PIDFILE`
  if /bin/kill -0 $PID > /dev/null 2> /dev/null
  then
    if /bin/ps $ps_options $PID | /bin/grep -v grep | /bin/grep stopreport > /dev/null
    then    # The pid contains a stopreport process
      echo "A stopreport process already exists"
      exit 1
    fi
  fi
fi


mysql -u $USERNAME -p$PASSWORD -h $DBHOST --execute="CALL process_stop_events()" --database="$DBNAME" &
echo $! > $PIDFILE