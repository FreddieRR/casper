# Terraform (AWS environment)

Infrastructure as code for Casper's AWS environment: a stand-in for "a customer's cloud", where tenant #2 is hosted. No `.tf` files exist yet; they arrive in week 8.

**Built in:** Week 8, Days 36–40.

## Rules

- **Personal AWS account only.** Never a risr/ account, profile or credentials.
- **No credentials in the repo.** Log in with IAM Identity Center (`aws sso login`); CI uses GitHub OIDC to assume a role.
- **State lives in S3**, versioned and encrypted, never in Git (`*.tfstate` and `.terraform/` are git-ignored).
- **Variables files** (`*.tfvars`) are git-ignored; commit a `*.tfvars.example` with placeholders.
- **Budget alarm first**, before creating anything else.

## Planned modules

| Module | Purpose | Plan day |
|---|---|---|
| `bootstrap` | S3 bucket for remote state (versioning, encryption, locking) | Day 36 |
| `backups` | Encrypted S3 bucket for Postgres backups, with a lifecycle rule | Day 36 |
| `ecr` | One container registry repository per service | Day 37 |
| `github-oidc` | OIDC provider and a least-privilege IAM role for CI deploys | Day 37 |
| `network` | VPC, subnets, route tables, security groups | Day 38 |
| `database` | RDS PostgreSQL with pgvector, or Postgres on EC2 (ADR) | Day 38 |
| `compute` | One EC2 instance running Compose, or ECS Fargate (ADR) | Days 38–39 |
| `secrets` | Secrets Manager or SSM Parameter Store (ADR) | Day 39 |
| `bedrock-access` | IAM role allowed to call only the required Bedrock models | Day 39 |
| `observability` | CloudWatch log groups and retention | Day 39 |

## Cost warnings

- **NAT (network address translation) gateway:** charged for every hour it exists plus data processed. The classic surprise bill. Find out whether you actually need one before creating it.
- **Idle RDS instance:** billed per hour even with no traffic. Stop or destroy it when not in use.
- **Load balancer:** also billed hourly whether or not it serves traffic.
- **Public IPv4 addresses:** charged per hour each.
- **CloudWatch Logs:** set a retention period; default is "never expire".
- **Bedrock:** pay per token; check pricing for the model and region.

Tear the environment down with `terraform destroy` whenever it isn't in use, and check Cost Explorer after the first few days.
