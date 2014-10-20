
CWD=`pwd`
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./bin"
export SANP_HOME=./
DATE=`date "+%Y-%m-%d_%H-%M-%S"`

while [ $# -gt 0 ]; do
	case $1 in
		rs)
			./redis/redis-server > rs.log.$DATE &
			echo $! >> pid
			;;
		gc)
			./bin/lua -l config -l libs -l gamecenter.config -l gamecenter.main > gc.log.$DATE &
			echo $! >> pid
			sleep 0.5s
			;;
		ws)
			./bin/lua -e "WSId = 1" -l config -l libs -l welcomeserver.main > ws.log.$DATE &
			echo $! >> pid
			;;
		gs1)
			./bin/lua -e "GSId = 1" -l config -l libs -l gameserver.config -l gameserver.main > gs1.log.$DATE &
			echo $! >> pid
			;;
		gs2)
			./bin/lua -e "GSId = 2" -l config -l libs -l gameserver.config -l gameserver.main > gs2.log.$DATE &
			echo $! >> pid
			;;
		gs3)
			./bin/lua -e "GSId = 3" -l config -l libs -l gameserver.config -l gameserver.main > gs3.log.$DATE &
			echo $! >> pid
			;;
		gs4)
			./bin/lua -e "GSId = 4" -l config -l libs -l gameserver.config -l gameserver.main > gs4.log.$DATE &
			echo $! >> pid
			;;
		ls1)
			./bin/lua -e "LSId = 1" -l config -l libs -l logserver.config -l logserver.main > ls1.log.$DATE &
			echo $! >> pid
			;;
		ls2)
			./bin/lua -e "LSId = 2" -l config -l libs -l logserver.config -l logserver.main > ls2.log.$DATE &
			echo $! >> pid
			;;
		ls3)
			./bin/lua -e "LSId = 3" -l config -l libs -l logserver.config -l logserver.main > ls3.log.$DATE &
			echo $! >> pid
			;;
		ls4)
			./bin/lua -e "LSId = 4" -l config -l libs -l logserver.config -l logserver.main > ls4.log.$DATE &
			echo $! >> pid
			;;
		sg)
			cd $CWD/sdkgateserver/execute
			java -Dfile.encoding=UTF-8 -jar Gate.jar > $CWD/sg.log.$DATE &
			echo $! >> $CWD/pid
			;;
		sb)
			cd $CWD/sdkbillingserver/execute
			java -Dfile.encoding=UTF-8 -jar Bill.jar > $CWD/sb.log.$DATE &
			echo $! >> $CWD/pid
			;;
	esac
	shift
done

