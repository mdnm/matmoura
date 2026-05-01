#!/bin/bash
set -euo pipefail

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

: "${AWS_ACCESS_KEY_ID:?Set AWS_ACCESS_KEY_ID in .env}"
: "${AWS_SECRET_ACCESS_KEY:?Set AWS_SECRET_ACCESS_KEY in .env}"
: "${AWS_REGION:=us-east-1}"
: "${S3_BUCKET:=akashic-harddrives}"
: "${S3_PREFIX:=yah/ai-business}"

SOURCE_DIR="public/ai-business"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "No course data at $SOURCE_DIR — run 'npm run build:course' first."
  exit 1
fi

echo "Uploading course data to s3://$S3_BUCKET/$S3_PREFIX/ ..."

aws s3 sync "$SOURCE_DIR" "s3://$S3_BUCKET/$S3_PREFIX" \
  --region "$AWS_REGION" \
  --content-type "application/json" \
  --cache-control "public, max-age=3600" \
  --delete

echo "Done. Files at https://$S3_BUCKET.s3.amazonaws.com/$S3_PREFIX/"
