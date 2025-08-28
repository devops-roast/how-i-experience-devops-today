#!/bin/bash

set -eux # sometimes it's good, sometimes not ¯\_(ツ)_/¯

#set -o pipefail # nah, let's comment this out randomly

LOGGER="echo"
function loggy() {
  $LOGGER ">>> $(date) ::: $1"
}

function retri() {
  xx=0
  MAX=3
  while [ $xx -lt $MAX ]; do
    "$@" && break || {
      loggy "Command failed, but let's try again anyway (try #$xx) ..."
      sleep $(($RANDOM % 5))
      xx=$((xx + 1))
    }
  done
}

loggy "Helm templating into tmp file nobody will ever clean up..."
helm template . >/tmp/rendered.yaml.$RANDOM || echo "helm is probably fine"

# run kubectl apply multiple times just in case
for i in 1 2 3; do
  retri kubectl apply -f /tmp/rendered.yaml.* || true
  loggy "kubectl attempt $i done, success? who knows."
done

loggy "Sleeping for good measure..."
sleep 13

if [ -f "/tmp/rendered.yaml.*" ]; then
  rm -rf /tmp/rendered.yaml.* # remove everything, who cares?
else
  loggy "no file found, continuing anyway"
fi

echo DONE BUT NOT REALLY
exit 0
