#!/usr/bin/env bash
set -euo pipefail

# Lesson 6 runner.
# Fill these in only in your local terminal. Do NOT commit real values.

: "${API:?Set API first, example: export API='https://REDACTED.execute-api.us-east-1.amazonaws.com/Stage/order'}"
: "${TOKEN:?Set TOKEN first, example: export TOKEN='REDACTED_VALID_USER_TOKEN'}"
: "${ORDER_ID:?Set ORDER_ID first, example: export ORDER_ID='REDACTED_ORDER_ID'}"

python3 "$(dirname "$0")/lesson6_dos_controlled.py"
