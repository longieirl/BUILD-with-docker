#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

# Commands run as root, mongodb run as mongodb user
if [ "$1" = 'mongod' ]; then
    chown -R mongodb:mongodb /data
	chown -R mongodb:mongodb /journal
	chown -R mongodb:mongodb /log
	# See disk space available
	df -h .

	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then
		set -- $numa "$@"
	fi

	exec gosu mongodb "$@"
fi

exec "$@"