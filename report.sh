#!/bin/bash

source ~/.bash_profile

id=$FARCASTER_ID
chain=mainnet
network=mainnet
type="hubble"
group=node
owner=$OWNER

docker_status=$(docker inspect hubble_hubble_1 | jq -r .[].State.Status)
version=$(docker logs hubble_hubble_1 2>&1 | grep -a "Hubble: " | tail -1 | awk -F "Hubble: " '{print $NF}'| awk -F '\\\\n' '{print $1}')

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "network":"$network",
  "status":"$status",
  "message":"$message",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$group,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
