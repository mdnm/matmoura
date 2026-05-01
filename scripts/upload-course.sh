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
: "${COURSE_SOURCE:=/Volumes/AKASH/YAH/ai-frontrunners}"

SOURCE_DIR="public/ai-business"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "No course data at $SOURCE_DIR — run 'npm run build:course' first."
  exit 1
fi

# Upload JSON files
echo "Uploading JSON course data..."
aws s3 sync "$SOURCE_DIR" "s3://$S3_BUCKET/$S3_PREFIX" \
  --region "$AWS_REGION" \
  --exclude "*.mp4" \
  --content-type "application/json" \
  --cache-control "public, max-age=3600"

# Upload videos from module-05
VIDEO_DIR="$COURSE_SOURCE/module-05-ai-creative"
if [ -d "$VIDEO_DIR" ]; then
  echo "Uploading videos from module-05..."
  for class_dir in "$VIDEO_DIR"/*/; do
    class_slug=$(basename "$class_dir")
    for mp4 in "$class_dir"*.mp4; do
      [ -f "$mp4" ] || continue
      # Skip macOS resource fork files
      [[ "$(basename "$mp4")" == ._* ]] && continue
      mp4_name=$(basename "$mp4")
      s3_key="$S3_PREFIX/videos/$class_slug/$mp4_name"
      echo "  $class_slug/$mp4_name"
      aws s3 cp "$mp4" "s3://$S3_BUCKET/$s3_key" \
        --region "$AWS_REGION" \
        --content-type "video/mp4" \
        --cache-control "public, max-age=86400"
    done
  done
else
  echo "No video directory found at $VIDEO_DIR — skipping video upload."
fi

echo "Done. Files at https://$S3_BUCKET.s3.amazonaws.com/$S3_PREFIX/"
