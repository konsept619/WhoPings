#!/bin/bash


set -e 

LOG_FILE="/var/tmp/whopings"
MSG_FILE="./notify.sh"
flag_provided=false
source_provided=false
LAST_IP=""


usage() {
  cat << EOF 
Usage: $0 [b|i|h|s] [interface] 
-b    "background"  To be used in cron; output will be redirected to log file 
-i    "interactive" Output will be shown in terminal.
-s    "source"      Source interface on wich you want to listen. 
-h    "help"        Displays help.

This script must be used with sudo privileges!
EOF
}

timestamp(){
  cat << EOF

=================================
$( date +"%F %T") 
Mode: $1

EOF
}

info_msg(){
  if [ ! -f $MSG_FILE ]; then
    echo "Couldn't find $MSG_FILE! Make sure there is proper file created! "
  else 
    $MSG_FILE $1
  fi

}
process_tcpdump_output(){
  while IFS= read -r line; do
    FOREIGN_IP=$(echo "$line" | awk '{print $3}' | cut -d. -f1-4 )
    if [[ "$FOREIGN_IP" != "$LAST_IP" ]];then 
      info_msg $FOREIGN_IP
      LAST_IP="$FOREIGN_IP"
    fi
  done
}

run_tcpdump() {
  #$1 is an interface on user wants to listen
  #$2 is an IP address user wants to exclude, to show only incoming traffic, not outcoming

  tcpdump -l -i $1 icmp and icmp[icmptype]=icmp-echo and not src host $2 -n | process_tcpdump_output 
}
background_mode(){
  echo "$0 is running in background. PID: $$ "
  timestamp 'background' >> $LOG_FILE
  run_tcpdump $1 $2 | tee -a "$LOG_FILE" &
}
interactive_mode(){
  timestamp 'interactive' >> $LOG_FILE
  run_tcpdump $1 $2 | tee -a "$LOG_FILE" 
}
get_IP(){
  #$1 is a interface from device
  IP_ADDR=$( ip -o -4 addr show "$1"| awk '{print $4}' | cut -d/ -f1 )

}
while getopts "s:bih" flag; do 
  flag_provided=true
  case "$flag" in
    b)
      b_flag=true
      ;;
    i) 
      i_flag=true
      ;;
    s)
      iface="$OPTARG"
      source_provided=true
      get_IP $iface
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "You need to specify correct option!"
      usage 
      exit 1
      ;;
  esac
done
#shift "$(($OPTIND -1))"
if  ! $flag_provided; then
  echo "You need to specify correct options!" >&2
  usage
  exit 1
fi 
if ! $source_provided; then
  echo "You need to specify correct source interface!" >&2
  usage
  exit 1
fi
#echo "b_flag =$b_flag , i_flag=$i_flag ,flag_provided= $flag_provided, iface= $iface, addr=$IP_ADDR"
if [ $b_flag ] && [ $i_flag ]; then
  echo "You can't use background and interactive mode at once!"
  usage 
  exit 1
fi
if [ ! $b_flag ] && [ ! $i_flag ]; then
  echo "You need to specifiy correct mode (-i or -b)!"
  usage 
  exit 1
fi

if [ -n "$i_flag" ]; then
  interactive_mode "$iface" "$IP_ADDR" 
elif [ -n "$b_flag" ]; then
  background_mode "$iface" "$IP_ADDR"
fi
