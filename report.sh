#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

docker_status=$(docker inspect hubble_hubble_1 | jq -r .[].State.Status)
version=$(docker logs hubble_hubble_1 2>&1 | grep -a "Hubble: " | tail -1 | awk -F "Hubble: " '{print $NF}'| awk -F '\\\\n' '{print $1}')

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac

cat << EOF
{

}
EOF

cat >$json << EOF
{ 
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
      "id":"$folder",
      "machine":"$MACHINE",
      "owner":"$OWNER",
      "grp":"node" 
  },
  "fields": {
      "version":"$version",
      "chain":"mainnet",
      "network":"mainnet",
      "status":"$status",
      "message":"$message",
      "docker_status":"$docker_status"
  }
}
EOF

cat $json | jq
