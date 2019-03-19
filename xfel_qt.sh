export CAQTDM_DISPLAY_PATH=/xfel/controls/App/config/qt
cd App/config/qt
echo PARAM1 $1
startDM -noMsg -attach -macro DEV=$1 $2 &

