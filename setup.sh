#!/bin/bash
#
# Usage: ./setup.sh <VM name> <remote IP> [options...]
#  -h, --help	This help text
#  -p, --port	Local listen port
#
# Example: ./setup.sh VirtualMachine 192.169.139.24 192.168.64.153

# the help() function displays a help text
help() {
  awk 'NR > 2 {
    if (/^#/) { sub("^# ?", ""); print }
    else { exit }
  }' $0
}

# default variables
LOCAL_PORT="4444"

# get local IP
LOCAL_IP=$(ip addr show dev tun0 | sed '1,2d' | sed '2,$d' | sed 's/.*inet \([0-9,\.]*\).*\([0-9]*\)/\1/')

# parse arguments
while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      help
      exit 0
      ;;
    -p | --port)
      LOCAL_PORT="$2"
      shift # past argument
      ;;
    -* | --*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      if [ -n "$VM_NAME" ]; then
        REMOTE_IP="$1"
      else
        VM_NAME="$1"
      fi
      ;;
  esac
  shift # past value
done

mkdir -p $VM_NAME/nmap
touch ./$VM_NAME/$VM_NAME.md

# create template

#------------------------------------------------------------------------
echo "# $VM_NAME

| Variable          | Value        |
| ----------------- | ------------ |
| Remote IP         | $REMOTE_IP  |
| Local IP          | $LOCAL_IP   |
| Local listen port | $LOCAL_PORT |

## Nmap
TCP port scan

\`\`\`bash
$ sudo nmap -sC -sV -oA namp/$VM_NAME $REMOTE_IP" >> ./$VM_NAME/$VM_NAME.md
#------------------------------------------------------------------------

sudo nmap -sC -sV -oA ./$VM_NAME/nmap/TCP_$VM_NAME $REMOTE_IP
cat ./$VM_NAME/$VM_NAME.md ./$VM_NAME/nmap/TCP_$VM_NAME.nmap >> ./$VM_NAME/$VM_NAME.md


#------------------------------------------------------------------------
echo "
\`\`\`

UDP port scan

\`\`\`bash
$ sudo nmap -Pn -sU --min-rate=10000 $REMOTE_IP
" >> ./$VM_NAME/$VM_NAME.md
#------------------------------------------------------------------------

sudo nmap -Pn -sU --min-rate=10000 -o ./$VM_NAME/nmap/UDP_$VM_NAME $REMOTE_IP
cat ./$VM_NAME/$VM_NAME.md ./$VM_NAME/nmap/UDP_$VM_NAME >> ./$VM_NAME/$VM_NAME.md

echo "\`\`\`" >> ./$VM_NAME/$VM_NAME.md

# launch obsidian

obsidian ./$VM_NAME/$VM_NAME.md
