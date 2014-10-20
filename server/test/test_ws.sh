
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:../bin"
cd `dirname $0`
if [ x$1 = x ]; then
	../bin/lua -l config test_ws.lua
	exit
fi
for ((i=0; i<$1; i++))
do
	../bin/lua -l config test_ws.lua > nul &
done
