#!/bin/bash
# Quick smoke test — create a bucket, upload, download, verify

set -e

echo "=== Floci S3 Smoke Test ==="

aws s3 mb s3://my-test-bucket
echo "Bucket created."

echo "Hello from Floci! Free AWS on your laptop." > /tmp/hello-floci.txt
aws s3 cp /tmp/hello-floci.txt s3://my-test-bucket/hello-floci.txt
echo "File uploaded."

aws s3 cp s3://my-test-bucket/hello-floci.txt /tmp/hello-back.txt
echo "File downloaded."

echo ""
echo "Contents:"
cat /tmp/hello-back.txt

echo ""
echo "All buckets:"
aws s3 ls

rm /tmp/hello-floci.txt /tmp/hello-back.txt
echo ""
echo "Test passed!"
