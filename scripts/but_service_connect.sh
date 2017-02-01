#!/bin/bash
#
#

function_help()
{
  echo "The script tries to connect to Button BPM service EPICS server"
  echo "with data from input script"
  echo
  echo "Usage: butbpm_updates_set.sh connection_string "
  echo "  connection_string - consists of hostname:port"
  echo 
}

if [ $# -lt 1 ]
then
  function_help
  exit 1
fi

CONN_STRING=$1
SERV_NAME=$2
SERV_ADDR="S7GPAC-ADDR"
SERV_STAT="S7GPAC-STATUS"

echo -n "Connecting to $CONN_STRING..."

caput "$SERV_NAME:$SERV_ADDR" $CONN_STRING >> NULL

if [ $? -ne 0 ] 
then 
  exit 2
fi

timeout=0

while [ 1 ]
do
  sleep 1
  echo -n "."
  # timeout=$timeout+1
  timeout=$(expr $timeout + 1)
  serv_stat=$(caget -plain "$SERV_NAME:$SERV_STAT")
  if [ $serv_stat -eq 1 ] 
  then
    echo "connection established"
    break
  fi
  if [ $timeout -gt 50 ]
  then
    echo "ERROR"
    exit 3
  fi
done

exit 0
