#!/bin/bash

set -e

RECEIPTS_BUCKET="dvsa-receipts-bucket-836739852202-us-east-1"
TEST_FILE="$HOME/dvsa_lesson4_empty"
TEST_KEY="2026/05/04/lesson4-proof.raw"

echo "[Lesson 4] Creating harmless test file..."
touch "$TEST_FILE"

echo "[Lesson 4] Uploading .raw object to receipts bucket..."
aws s3 cp "$TEST_FILE" "s3://$RECEIPTS_BUCKET/$TEST_KEY"

echo
echo "[Lesson 4] Upload complete."
echo
echo "Now check CloudWatch log group:"
echo "/aws/lambda/DVSA-SEND-RECEIPT-EMAIL"
echo
echo "Expected evidence before fix:"
echo "- START RequestId"
echo "- END RequestId"
echo "- REPORT RequestId"
echo "- possible IndexError before fix"
echo
echo "Screenshot to take:"
echo "evidence/lesson-04/l04-03-cloudwatch-lambda-triggered-before.png"
