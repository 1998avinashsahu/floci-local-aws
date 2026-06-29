# How to Use — floci-local-aws

This guide walks through real AWS workflows you can practice locally using Floci — the same commands you'd use in a real AWS environment.

---

## Setup (once per machine)

```bash
# 1. Clone this repo
git clone https://github.com/1998avinashsahu/floci-local-aws.git
cd floci-local-aws

# 2. Start Floci
./start-floci.sh

# 3. In every new terminal session, load env vars
source aws-env.sh
```

---

## S3 — Object Storage

```bash
# Create bucket
aws s3 mb s3://my-app-bucket

# Upload file
aws s3 cp app.zip s3://my-app-bucket/releases/app.zip

# List contents
aws s3 ls s3://my-app-bucket/

# Download file
aws s3 cp s3://my-app-bucket/releases/app.zip ./app-downloaded.zip

# Sync entire directory
aws s3 sync ./dist s3://my-app-bucket/static/

# Delete bucket (must be empty first)
aws s3 rm s3://my-app-bucket --recursive
aws s3 rb s3://my-app-bucket
```

---

## SQS — Message Queue

```bash
# Create a standard queue
aws sqs create-queue --queue-name my-queue

# Send a message
aws sqs send-message \
  --queue-url http://localhost:4566/000000000000/my-queue \
  --message-body "Hello from Floci"

# Receive messages
aws sqs receive-message \
  --queue-url http://localhost:4566/000000000000/my-queue

# Delete a message (use ReceiptHandle from receive output)
aws sqs delete-message \
  --queue-url http://localhost:4566/000000000000/my-queue \
  --receipt-handle "<ReceiptHandle>"

# Create FIFO queue
aws sqs create-queue \
  --queue-name my-fifo.fifo \
  --attributes FifoQueue=true,ContentBasedDeduplication=true
```

---

## Secrets Manager

```bash
# Store a secret
aws secretsmanager create-secret \
  --name /myapp/db/password \
  --secret-string "supersecretpassword"

# Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id /myapp/db/password

# Update secret
aws secretsmanager put-secret-value \
  --secret-id /myapp/db/password \
  --secret-string "newpassword123"

# Store JSON secret (DB credentials)
aws secretsmanager create-secret \
  --name /myapp/db/credentials \
  --secret-string '{"username":"admin","password":"pass123","host":"localhost"}'

# List all secrets
aws secretsmanager list-secrets
```

---

## Lambda — Serverless Functions

```bash
# Create a simple Lambda zip
mkdir lambda-hello && cd lambda-hello
cat > index.js << 'EOF'
exports.handler = async (event) => {
  return { statusCode: 200, body: "Hello from Lambda!" };
};
EOF
zip function.zip index.js
cd ..

# Create Lambda function
aws lambda create-function \
  --function-name hello-function \
  --runtime nodejs18.x \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler index.handler \
  --zip-file fileb://lambda-hello/function.zip

# Invoke Lambda
aws lambda invoke \
  --function-name hello-function \
  --payload '{"key":"value"}' \
  output.json

cat output.json

# List functions
aws lambda list-functions

# Update function code
aws lambda update-function-code \
  --function-name hello-function \
  --zip-file fileb://lambda-hello/function.zip
```

---

## DynamoDB — NoSQL Database

```bash
# Create table
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions AttributeName=userId,AttributeType=S \
  --key-schema AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Insert item
aws dynamodb put-item \
  --table-name Users \
  --item '{"userId":{"S":"user-001"},"name":{"S":"Avinash"},"role":{"S":"DevOps"}}'

# Get item
aws dynamodb get-item \
  --table-name Users \
  --key '{"userId":{"S":"user-001"}}'

# Scan table
aws dynamodb scan --table-name Users

# Query with filter
aws dynamodb query \
  --table-name Users \
  --key-condition-expression "userId = :id" \
  --expression-attribute-values '{":id":{"S":"user-001"}}'

# List tables
aws dynamodb list-tables
```

---

## KMS — Key Management Service

```bash
# Create a key
aws kms create-key --description "My encryption key"

# Note the KeyId from output, then create alias
aws kms create-alias \
  --alias-name alias/my-key \
  --target-key-id <KeyId>

# Encrypt data
aws kms encrypt \
  --key-id alias/my-key \
  --plaintext "my-secret-data" \
  --query CiphertextBlob \
  --output text > encrypted.b64

# Decrypt data
aws kms decrypt \
  --ciphertext-blob fileb://<(base64 -d encrypted.b64) \
  --query Plaintext \
  --output text | base64 -d

# List keys
aws kms list-keys
```

---

## EventBridge — Event Bus

```bash
# Create a custom event bus
aws events create-event-bus --name my-event-bus

# Create a rule
aws events put-rule \
  --name my-rule \
  --event-bus-name my-event-bus \
  --event-pattern '{"source":["my.app"]}' \
  --state ENABLED

# Send custom events
aws events put-events \
  --entries '[{
    "Source": "my.app",
    "DetailType": "UserSignup",
    "Detail": "{\"userId\":\"user-001\",\"email\":\"user@example.com\"}",
    "EventBusName": "my-event-bus"
  }]'

# List rules
aws events list-rules --event-bus-name my-event-bus
```

---

## SNS — Simple Notification Service

```bash
# Create topic
aws sns create-topic --name my-notifications

# List topics
aws sns list-topics

# Subscribe SQS to SNS (fan-out pattern)
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-notifications \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:my-queue

# Publish message
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-notifications \
  --message "Deployment successful!" \
  --subject "CI/CD Notification"
```

---

## CloudFormation — Infrastructure as Code

```bash
# Create a sample template
cat > stack.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-cfn-bucket
  MyQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: my-cfn-queue
EOF

# Deploy stack
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://stack.yaml

# Check stack status
aws cloudformation describe-stacks --stack-name my-stack

# List stack resources
aws cloudformation list-stack-resources --stack-name my-stack

# Delete stack
aws cloudformation delete-stack --stack-name my-stack
```

---

## EKS — Elastic Kubernetes Service

```bash
# Create EKS cluster
aws eks create-cluster \
  --name my-cluster \
  --role-arn arn:aws:iam::000000000000:role/eks-role \
  --resources-vpc-config subnetIds=subnet-00000000,securityGroupIds=sg-00000000

# List clusters
aws eks list-clusters

# Describe cluster
aws eks describe-cluster --name my-cluster

# Create node group
aws eks create-nodegroup \
  --cluster-name my-cluster \
  --nodegroup-name my-nodes \
  --scaling-config minSize=1,maxSize=3,desiredSize=2 \
  --node-role arn:aws:iam::000000000000:role/node-role \
  --subnets subnet-00000000
```

---

## Daily Workflow

```
Morning                         Evening
  │                               │
  ▼                               ▼
./start-floci.sh           ./stop-floci.sh
source aws-env.sh
  │
  ▼
practice any AWS service
(same commands as real AWS)
```

---

## Environment Variables Reference

| Variable | Value | Purpose |
|----------|-------|---------|
| `AWS_ENDPOINT_URL` | `http://localhost:4566` | Redirects all AWS CLI calls to Floci |
| `AWS_ACCESS_KEY_ID` | `test` | Dummy credential (Floci doesn't validate) |
| `AWS_SECRET_ACCESS_KEY` | `test` | Dummy credential |
| `AWS_DEFAULT_REGION` | `us-east-1` | Default region for all commands |

---

## Tips for Interview Demos

1. **Show the workflow**: `start → source env → run commands` — demonstrates environment setup skills
2. **Use real CLI flags**: always use `--output json` or `--query` to show CLI proficiency
3. **Chain services**: e.g., S3 + Lambda + SQS together shows architecture thinking
4. **Mention the concept**: "I use Floci to emulate AWS locally — same API contract, zero cost, no credentials risk"
