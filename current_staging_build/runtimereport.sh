#!/bin/bash
export PATH=/usr/bin
PIDFILE=/var/run/ublip_db/runtimereport.pid
ps_options="p"
if test -f $PIDFILE
then
  PID=`/bin/cat $PIDFILE`
  if /bin/kill -0 $PID > /dev/null 2> /dev/null
  then
    if /bin/ps $ps_options $PID | /bin/grep -v grep | /bin/grep runtimereport > /dev/null
    then    # The pid contains a runtimereport process
      echo "A runtimereport process already exists"
      exit 1
    fi
  fi
fi


mysql -u $USERNAME -p$PASSWORD -h $DBHOST --execute="CALL process_runtime_events()" --database="$DBNAME" &
echo $! > $PIDFILE