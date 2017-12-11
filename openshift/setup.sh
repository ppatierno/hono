#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

 : "${PROJECT:=hono}
 : "${CONFIG_DIR:=$SCRIPT_DIR/../example/target/config}

oc -n "$PROJECT" create configmap influxdb-config --from-file="$CONFIG_DIR/influxdb.conf"

curl -X PUT -T "$SCRIPT_DIR/addresses.json" -H "content-type: application/json" http://$(oc -n "$PROJECT" get route restapi -o jsonpath='{.spec.host}')/v1/addresses/default
