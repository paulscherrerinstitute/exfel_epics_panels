export CAQTDM_DISPLAY_PATH=/xfel/controls/App/config/qt
cd App/config/qt
startDM -noMsg -attach -macro DEV=$1 $2 &

