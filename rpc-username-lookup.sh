#!/bin/bash
# Descr: User-enumeration script based on rpcclient
# Author: Jacco van Buuren
# License: GPLv2

MAXFORK=10	# Please be gentle and don't set this too high

if [ "$#" -lt 1 ]; then
	echo "Missing parameter. Use: $0 <TARGET-IP-ADDRESS> [initial-username] [password]"
fi

IP="$1"
U1="${2:-guest}"
P1="${3}"

echo "[!] Using \"$U1\" and \"$P1\" for authentication on $IP"

rpcclient -U "${U1}%${P1}" -c 'srvinfo' "$IP" &>/dev/null
if [ "$?" -ne 0 ]; then
	echo "Failed to authenticate using \"$U1\" and password \"$P1\". Aborted" >&2
	exit 1
fi

SID=$(rpcclient -U "${U1}%${P1}"  -c "lookupnames ${U1}" "$IP" 2>/dev/null | awk '{print $2}')
#guest S-1-5-21-917908876-1423158569-3159038727-501 (User: 1)

BASE="$(echo $SID | sed 's/\-[0-9]*$//')"

FORK="$MAXFORK"
for i in {500..550} {1000..1050}
do
	( rpcclient -U "${U1}%${P1}" -c "lookupsids ${BASE}-$i" "$IP" 2>&1 | grep -v '.unknown...unknown. .8.' ) &
	FORK="$((FORK-1))"
	if [ "$FORK" -le 0 ]; then
		wait
		FORK="$MAXFORK"
	fi
done

wait -n
exit 0
                 
