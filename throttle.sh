#!/bin/bash -ex
# script to throttle 'bandwidth' on port 3000 to simulate slow connections
# probably only works on OS X and Gnu systems with ipfw set up.

[ $UID == 0 ] || { echo "you must be superuser to run this"; exit 1; }

ipfw pipe 1 config bw 15kbyte/s
ipfw add 1 pipe 1 src-port 3000
echo "port 3000 throttled now, unthrottle by: sudo ipfw delete 1"
