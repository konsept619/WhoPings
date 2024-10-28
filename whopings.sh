#!/bin/bash

LOG_FILE="/var/tmp/whopings"

set -e 

usage() {
  cat << EOF 
This script must be used with sudo privileges
Usage: $0 [interface] [options]
-b    "background"  To be used in cron; output will be redirected to log file 
-i    "interactive" Output will be shown in terminal.
-h    "hepl"        Displays help.
EOF
}
while getopts "b:i:h-:" flag; do 
  case "$flag" in
    b)
      echo "$0 is running in background. PID: $$ "
      tcpdump -i $OPTARG icmp and icmp[icmptype]=icmp-echo -n &>> $LOG_FILE &
      ;;
    i) 
      tcpdump -i $OPTARG icmp and icmp[icmptype]=icmp-echo -n
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
    echo "Invalid option: -$OPTARG"
    exit 1
    ;;
  esac
done
