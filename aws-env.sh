#!/bin/bash
# Source this file to point AWS CLI at local Floci
# Usage: source aws-env.sh

export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "AWS CLI now points to local Floci (http://localhost:4566)"
echo "Region: us-east-1"
