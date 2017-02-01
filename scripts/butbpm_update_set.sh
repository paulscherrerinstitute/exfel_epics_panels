#!/bin/bash
#
# $1 - file list with Button BPMs
#
#


function_help()
{
	echo
  echo "The script updates parameters set in BPM EEPROM"
}

function_usage()
{
  echo
  echo "Usage: butbpm_update_set.sh <-f host_list> [-d dev_name] <-i init_script> <-s set> [-default]"
  echo "  -f host_list      - file with list of hosts"
  echo "  -d dev_name       - update a single Button BPM device"
  echo "  -i init_script    - use this init_script to update EPICS records"
  echo "  -s set            - parameters set to be update from 0 to 14"
  echo "  -d                - set it as default set"
  echo 
  echo "Example: butbpm_update_set.sh -f butbpm.list -d BPMC-38I-I1 -i initxfel.sh -s 1 -default"
  echo
  echo
}

save_data_to_eeprom() 
{
	EEPROM_SELECT_SET="BPM-EEPROM-SELECT-SET"
	EEPROM_SET_DESC="BPM-EEPROM-SET-DESC"	
	EEPROM_ATT_LIMIT="BPM-EEPROM-ATTN-LIMIT"
	EEPROM_DEV_NAME="DEV-NAME"
	EEPROM_CMD="BPM-EEPROM-CMD"
	EEPROM_CMD_DEFAULT=1
	EEPROM_CMD_SAVE=2
	EEPROM_CMD_SET_LOAD=4
	EEPROM_CMD_SET_SAVE=5
	EEPROM_CMD_SET_DEFAULT=3

  # set record values
	caput "$SERV_NAME:$EEPROM_SELECT_SET" $set_num
	caput "$SERV_NAME:$EEPROM_SET_DESC" "$set_desc"
	caput "$SERV_NAME:$EEPROM_DEV_NAME" $next_dev
	caput "$SERV_NAME:$EEPROM_ATT_LIMIT" 22

  # save set
  	sleep 0.3
	caput "$SERV_NAME:$EEPROM_CMD" $EEPROM_CMD_SET_SAVE
	sleep 0.3
	caput "$SERV_NAME:$EEPROM_CMD" 0
	sleep 0.3
  
  # set as default 
  if [ $default_set -eq 1 ]; then
	caput "$SERV_NAME:$EEPROM_CMD" $EEPROM_CMD_SET_DEFAULT
	sleep 0.3
	caput "$SERV_NAME:$EEPROM_CMD" 0 
	sleep 0.3
  fi
  
  # save eeprom
	caput "$SERV_NAME:$EEPROM_CMD" $EEPROM_CMD_SAVE
	sleep 0.3
	caput "$SERV_NAME:$EEPROM_CMD" 0
	sleep 0.3
}

# Parameters initialization 
default_set=0
set_desc="XFEL init"
SERV_NAME="BUTBPMSERV"

# Arguments parsing

while [ $1 ]
do
	case "$1" in
	-f)	host_list=$2
			shift
			shift
      ;;
	-d)	dev_name=$2
			shift
			shift
      ;;
	-i)	init_script=$2
			shift
			shift
      ;;
	-s)	
      set_num=$2
			shift
			shift
			;;
	-default)	
  	  default_set=1
			shift
      ;;
	--help)	
			function_help
      function_usage
			exit 1			
      ;;
	-*)	echo "ERROR: Unknown option $1"
			function_usage
			exit 1
      ;;
	esac
done

# Arguments check

if [ "$host_list" == "" ]
then
	echo "ERROR: missing host_list"
  function_usage
  exit 1
fi

if [ "$init_script" == "" ] 
then
	echo "ERROR: missing init script"
  function_usage
  exit 1
fi

if [ "$set_num" == "" ] 
then
	echo "ERROR: missing set number"
  function_usage
  exit 1
fi

if [ $set_num -lt 0 ] || [ $set_num -gt 14 ]
then
	echo "ERROR: invalid set number"
  function_usage
  exit 1	
fi

if [ ! "$host_list" == "" ]
then
	if [ ! -f $host_list ]
	then
	  echo "ERROR: file $host_list does not exists" 
	  exit 10
	fi  
fi

if [ ! -f $init_script ]
then
  echo "ERROR: file $init_script does not exists" 
  exit 11
fi  

while read -r myline || [[ -n "$myline" ]]; do
  if [[ ${myline:0:1} == "#" ]]
  then 
    continue
  fi
  next_dev=$(echo $myline | awk '{print $1}')
  if ( [ ! "$dev_name" == "" ] && [ "$dev_name" == "$next_dev" ] ) || ( [ "$dev_name" == "" ] )
  then
	  connection_string=$(echo $myline | awk '{print $2}')
  	echo
	  echo "__________________________ $next_dev ($connection_string) ________________________________"
  else
  	continue
  fi
  but_service_connect.sh $connection_string $SERV_NAME
  if [ $? -ne 0 ]; then
    continue
  fi
  echo -n "Updating EPICS records..."
  source $init_script $next_dev >> NULL
  if [ $? -ne 0 ]; then
    continue
  fi  
  echo "done"
  echo -n "Saving data to set $set_num in EEPROM..."
  save_data_to_eeprom >> NULL
  echo "done"
done < "$host_list"

