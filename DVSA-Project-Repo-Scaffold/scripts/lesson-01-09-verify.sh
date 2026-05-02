#!/usr/bin/env bash
set -e

API="${1:-}"

if [ -z "$API" ]; then
  echo "Usage: $0 <full-order-api-url>"
  exit 1
fi

curl -X POST "$API" \
  -H 'Content-Type: application/json' \
  -d '{"action":"_$$ND_FUNC$$_function(){var fs=require(\"fs\");fs.writeFileSync(\"/tmp/pwned.txt\",\"You are reading the contents of my hacked file!\");var fileData=fs.readFileSync(\"/tmp/pwned.txt\",\"utf-8\");console.error(\"FILE READ SUCCESS: \"+fileData);}()","cart-id":""}'

echo
echo "[+] After the fix, CloudWatch should NOT contain:"
echo "    FILE READ SUCCESS: You are reading the contents of my hacked file!"
echo "[+] Also confirm a normal order-related action still works in DVSA."
