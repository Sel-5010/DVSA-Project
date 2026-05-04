#!/bin/bash

set -e

RECEIPTS_BUCKET="dvsa-receipts-bucket-836739852202-us-east-1"
TEST_FILE="$HOME/dvsa_lesson4_empty"
SUSPICIOUS_KEY="2026/05/04/null_;echo DVSA_LESSON4_MARKER;echo x.raw"

echo "[Lesson 4] Creating harmless test file..."
touch "$TEST_FILE"

echo "[Lesson 4] Uploading suspicious object key after fix..."
aws s3 cp "$TEST_FILE" "s3://$RECEIPTS_BUCKET/$SUSPICIOUS_KEY"

echo
echo "[Lesson 4] Upload complete."
echo
echo "Now check CloudWatch log group:"
echo "/aws/lambda/DVSA-SEND-RECEIPT-EMAIL"
echo
echo "Expected post-fix evidence:"
echo "Rejected suspicious receipt key"
echo
echo "Screenshot to take:"
echo "evidence/lesson-04/l04-04-suspicious-key-rejected-after-fix.png"
