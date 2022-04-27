#!/usr/bin/env bash
# This is the script to scan keys in redis.
# Usage:
#      ./redis-scan.sh localhost 6378 password 0 '*test*'
#

if [ "$#" -lt 2 ]
then
  echo "Scan keys in Redis matching a pattern using SCAN (safe version of KEYS)"
  echo "Usage: $0 <host> [port] [auth] [database] [pattern]"
  exit 1
fi
host=${1:-}
port=${2:-6379}
auth=${3:-}
database=${4:-0}
pattern=${5:-\*}
cursor=-1
keys=""

echo "host=${host},port=${port},auth=${auth},database=${database}"

redisconcmd="redis-cli -h ${host} -p ${port}  -n ${database}"

if [[ -z "$auth" ]]
then
	echo "no auth option"
else
	redisconcmd="${redisconcmd} --no-auth-warning -a ${auth}" 
	echo $redisconcmd
fi

while [[ "$cursor" -ne 0 ]]; do
  if [[ "$cursor" -eq -1 ]]
  then
    cursor=0
  fi

  reply=`$redisconcmd SCAN ${cursor} MATCH "${pattern}"`
  #reply=$(redis-cli -h "$host" -p "$port" "$authOption" -n "$database" SCAN "$cursor" MATCH "$pattern")
  #reply=$scankeycmd
  cursor=$(expr "$reply" : '\([0-9]*[0-9 ]\)')
  keys=${reply//$cursor/}
  if [ -n "$keys" ]; then
    echo "$keys"
  fi
done
