#!/bin/sh
# 
# Waldemar Koprek (PSI)
# 11.01.2018
# 
# This command powers on GPAC in an MBU
#
# Usage from bash:
#	mbuon.sh <mmc2_hostname>
#
# 
echo -n > empty.bin
tftp $1 << 'ENDTFTP'
binary
put empty.bin PWR_ON
quit
ENDTFTP

