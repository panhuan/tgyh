
if [ -r pid ]; then
	cat pid | while read i
	do kill $i
	done
fi
rm -f pid
