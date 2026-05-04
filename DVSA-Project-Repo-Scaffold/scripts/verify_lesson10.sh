API="https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/YOUR_STAGE/order"
TOKEN="PASTE_REDACTED_TOKEN_HERE"

echo
echo "============================================================"
echo "Lesson 10 - Verify Fix"
echo "============================================================"
echo
echo "[*] Target API:"
echo "$API"
echo
echo "[*] Sending the same malformed request after the fix:"
echo '{ "action": "get" }'
echo
echo "[*] Expected result: safe generic error only."
echo

curl -s "$API" \
  -H "content-type: application/json" \
  -H "authorization: $TOKEN" \
  --data-raw '{
    "action": "get"
  }' | jq

echo
echo "============================================================"
echo "Expected secure behavior:"
echo "============================================================"
echo '{"status":"err","msg":"invalid request"}'
echo
echo "The response should NOT contain:"
echo "- stackTrace"
echo "- errorType"
echo "- errorMessage"
echo "- /var/task/"
echo "- internal file paths"
echo "- source-code lines"
echo
echo "Take screenshot:"
echo "evidence/lesson-10/lesson10_04_post_fix_safe_error.png"
echo "============================================================"
