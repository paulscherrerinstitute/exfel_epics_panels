#!/bin/bash
DIR=$(readlink -f "$0")
DIR=$(dirname ${DIR})
echo DIR is: $DIR

export CAQTDM_DISPLAY_PATH=$DIR/App/config/qt
cd $DIR/App/config/qt

echo command = startDM -noMsg -attach -macro DEV=$1 $2 
startDM -noMsg -attach -macro DEV=$1 $2 
#startDM -noMsg -macro DEV=$1 $2 

