#!/bin/bash
export PATH=/usr/bin
PIDFILE=/var/run/ublip_db/transientreport.pid
ps_options="p"
if test -f $PIDFILE
then
  PID=`/bin/cat $PIDFILE`
  if /bin/kill -0 $PID > /dev/null 2> /dev/null
  then
    if /bin/ps $ps_options $PID | /bin/grep -v grep | /bin/grep transientreport > /dev/null
    then
      echo "A transientreport process already exists"
      exit 1
    fi
  fi
fi


mysql -u root -pru5heZeW -h localhost --execute="CALL process_transient_devices()" --database="ublip_prod" &
echo $! > $PIDFILE
