#!/bin/sh
# 
# Waldemar Koprek (PSI)
# 11.01.2018
# 
# This command powers off GPAc in an MBU. The MMC2 stays on.
# 
# Usage from bash:
#	mbuon.sh <mmc2_hostname>
#
# 
echo -n > empty.bin
tftp $1 << 'ENDTFTP'
binary
put empty.bin PWR_OFF
quit
ENDTFTP

