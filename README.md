# floci-local-aws

> Run AWS on your laptop — free, no credit card, no account needed.

A ready-to-use local AWS emulation environment powered by [Floci](https://github.com/floci-io/floci). Spin up S3, EKS, Lambda, SQS, Secrets Manager, EventBridge, KMS and 40+ more AWS services on your machine using the exact same AWS CLI commands you'd use in production.

---

## Why This Exists

Learning AWS usually means one of two things:
- Burn through free-tier credits in a few days
- Get an unexpected bill on your credit card

This repo removes that barrier entirely. Every AWS CLI command you run hits a **local emulator** that returns real AWS-shaped responses — zero cost, zero risk.

---

## Supported AWS Services (47+)

| Category | Services |
|----------|----------|
| Storage | S3 |
| Compute | Lambda, EKS, ECS |
| Messaging | SQS, SNS, EventBridge |
| Security | KMS, Secrets Manager, IAM |
| Database | DynamoDB, RDS, ElastiCache |
| Networking | VPC, Route53, API Gateway |
| DevOps | CloudFormation, CodeDeploy, CloudWatch |

Full list: [floci.io/floci/services](https://floci.io/floci/services/)

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (running)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

That's it. No AWS account. No credit card.

---

## Quick Start (3 steps)

### 1. Start Floci

```bash
./start-floci.sh
```

### 2. Point AWS CLI at Floci

```bash
source aws-env.sh
```

### 3. Use AWS CLI normally

```bash
# Create an S3 bucket
aws s3 mb s3://my-bucket

# Upload a file
aws s3 cp myfile.txt s3://my-bucket/

# List buckets
aws s3 ls
```

---

## Project Structure

```
floci-local-aws/
├── start-floci.sh   # Start (or restart) the Floci Docker container
├── stop-floci.sh    # Stop the container
├── aws-env.sh       # Export env vars to redirect AWS CLI → Floci
├── test-s3.sh       # S3 smoke test (create bucket → upload → download)
└── docs/
    └── HOW_TO_USE.md   # Detailed usage guide with service examples
```

---

## Verify It Works

```bash
source aws-env.sh
bash test-s3.sh
```

Expected output:
```
=== Floci S3 Smoke Test ===
Bucket created.
File uploaded.
File downloaded.

Contents:
Hello from Floci! Free AWS on your laptop.

All buckets:
2026-06-29 15:31:15 my-test-bucket

Test passed!
```

---

## Stop Floci

```bash
./stop-floci.sh
```

---

## How It Works

```
Your Terminal
     │
     │  aws s3 ls   (AWS CLI command)
     ▼
AWS_ENDPOINT_URL=http://localhost:4566
     │
     ▼
Floci Docker Container  ←── emulates AWS API
     │
     └── returns real AWS-shaped JSON responses
         (no network call to AWS ever made)
```

The env vars in `aws-env.sh` intercept every AWS CLI / SDK call and redirect it to the local Floci container instead of real AWS endpoints.

---

## Use with AWS SDKs

Works with any language SDK that respects `AWS_ENDPOINT_URL`:

**Python (boto3)**
```python
import boto3

s3 = boto3.client("s3")  # picks up AWS_ENDPOINT_URL automatically
s3.create_bucket(Bucket="my-bucket")
```

**Node.js**
```javascript
const { S3Client, ListBucketsCommand } = require("@aws-sdk/client-s3");

const client = new S3Client({
  endpoint: "http://localhost:4566",
  region: "us-east-1",
  credentials: { accessKeyId: "test", secretAccessKey: "test" },
});
```

**Terraform**
```hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Connection refused` | Run `./start-floci.sh` first |
| `UnauthorizedException` | Run `source aws-env.sh` in your current terminal |
| Container won't start | Check Docker is running: `docker info` |
| Port conflict | Another service on 4566 — stop it or change the port in `start-floci.sh` |

---

## Credits

- [Floci](https://github.com/floci-io/floci) — the open-source AWS emulator this repo wraps
- Inspired by [LocalStack](https://localstack.cloud/) (enterprise) — Floci is the free alternative

---

## Author

**Avinash Sahu** — DevOps Engineer  
[GitHub](https://github.com/1998avinashsahu) · [LinkedIn](https://www.linkedin.com/in/avinash-sahu-0ba434181/)
