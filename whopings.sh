#!/bin/bash

INTERFACE=$1
LOG_FILE="/var/tmp/whopings"

set -e 

usage() {
cat << EOF 
This script must be used with sudo privileges
Usage: $0 [interface] [options]
-b | --background   To be used in cron; output will be redirected to log file 
-i | --interactive  Output will be shown in terminal.
-h | --help         Displays help.
EOF
}
while getopts "b:i:h-:" flag; do 
  case "$flag" in
    b|background)
      echo "$0 is running in background. PID: $$ "
      tcpdump -i $OPTARG icmp and icmp[icmptype]=icmp-echo -n &>> $LOG_FILE &
      ;;
    i|interactive) tcpdump -i $OPTARG icmp and icmp[icmptype]=icmp-echo -n
      ;;
    h|help) usage
      exit 0
      ;;
    \?) usage 
      exit 1
      ;;
  esac


done
