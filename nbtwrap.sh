#!/bin/bash

RANGE=

while getopts ":r:" OPTIONS
do
            case $OPTIONS in
            r)     RANGE=$OPTARG;;
            ?)     printf "Invalid option: -$OPTARG\n" $0
                          exit 2;;
           esac
done

RANGE=${RANGE:=NULL}

if [ $RANGE = NULL ]; then

	echo '  ----------------------------------------------------------- '
	echo '(                 _   _   _   _   _   _   _                   )'
	echo '(                / \ / \ / \ / \ / \ / \ / \                  )'
	echo '(               ( n | b | t | W | r | a | p )                 )'
	echo '(                \_/ \_/ \_/ \_/ \_/ \_/ \_/                  )'
	echo '(                                                             )'
	echo '(-------------------------------------------------------------)'
	echo '(                 Simple wrapper for nbtscan!                 )'
	echo '(                [Groups, IPs, hostnames, DCs]                )'
	echo '(                                                             )'
	echo '(  USAGE:                                                     )'
	echo '(  ./nbtwrap.sh -r 10.1.1.0/24                                )'
	echo '  ----------------------------------------------------------- '

else

	#Just to make a clean start
	rm nbtscan.out &>/dev/null

	# Verbose + scriptable output
	nbtscan -v -r -q -s : $RANGE > nbtscan.out

	# Yes, some very nasty grepping...
	#$group=groupname $member=IP $name=hostname $DC=DCflag
	for group in $(cat nbtscan.out |grep ":00G" |cut -d":" -f2 |cut -d" " -f1 |sort |uniq |egrep -v "IS~|INet~|MAC"); do
		echo "$group contains:"
		for member in $(cat nbtscan.out |grep $group |cut -d":" -f1 |sort |uniq); do
			DC=$(cat nbtscan.out |grep $member |egrep -v "INet~" |grep -ci ":1c")
			for name in $(cat nbtscan.out |grep $member |grep :00U |uniq |cut -d":" -f2 |cut -d" " -f1 |egrep -v "IS~|INet~|MAC"); do
				if [ "$DC" == 1 ]; then
					echo "IP: $member => $name   [This is a DC!!]"
				else
					echo "IP: $member => $name"
				fi
			done
		done
		echo ""
	done
	rm nbtscan.out

fi