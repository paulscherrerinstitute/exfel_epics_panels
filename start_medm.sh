
if [[ $1 == "--help" ]]; then
	echo "usage: start_medm.sh [--devl]"
	exit 0
fi;

if [[ $1 == "--devl" ]]; then
	echo "MEDM development mode started..."
	params=""
else
	params="-x -dg +0+0" 
fi;

medm $params App/config/medm/XFEL.adl &

