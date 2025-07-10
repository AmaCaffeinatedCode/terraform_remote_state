# Terraform Remote State Management

---

## Project Overview

This project provisions a centralized and secure remote backend using AWS services to manage Terraform state. It creates an S3 bucket for storing state files and a DynamoDB table for state locking, enabling safe collaboration and consistent deployments across environments.

---

## Resources Created
- AWS S3 bucket for storing Terraform state files  
- AWS DynamoDB table for state locking  

## Backend Setup Process
- Initialized local backend for bootstrapping  
- Migrated backend to remote state after provisioning  

---

## Usage

### 1. Environment variables

The GitHub Actions CI/CD pipeline uses the following secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. Deployment

**Step 1: Bootstrap the backend**

Before the remote backend can be used, it must be provisioned using a local backend. Clone the repository and run:

``` bash
terraform init
terraform plan
terraform apply
```

**Step 2: Switch to the remote backend**

After successful provisioning, update the `backend.tf` to point to the newly created S3 bucket and DynamoDB table:

``` hcl
terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-central-bucket"
    key            = "terraform_remote_state/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state-lock-table"
    encrypt        = true
  }
}
```

Then reinitialize Terraform:

``` bash
terraform init -reconfigure
```

**Step 3: Use this backend in other projects**

Other Terraform projects should reference the same backend, using a unique key per project and environment:

``` hcl
terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-central-bucket"
    key            = "project_name/environment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state-lock-table"
    encrypt        = true
  }
}
```

---

## CI/CD Pipeline

A GitHub Actions workflow (`.github/workflows/deploy.yml`) is included to automate Terraform deployment on every push.

The pipeline:
- Sets required environment variables  
- Initializes Terraform  
- Executes Terraform plan and apply to provision resources  
- Detects `[skip-ci]` commit flag to optionally skip execution  

It uses GitHub Actions environment secrets for secure authentication. 

---

## Variables

| Variable             | Description                                  |
|----------------------|----------------------------------------------|
| aws_region           | AWS region for resource deployment           |
| s3_bucket_name       | Name of the S3 bucket for state files        |
| dynamodb_table_name  | Name of the DynamoDB table for locking       |

---

## Outputs

| Name               | Description                                           |
|--------------------|-------------------------------------------------------|
| bucket_id          | The ID of the S3 bucket                               |
| bucket_arn         | The ARN of the S3 bucket                              |
| bucket_name        | The unique name of the S3 bucket                      |
| dynamodb_table_name| The name of the DynamoDB table used for state locking |
| dynamodb_table_arn | The ARN of the DynamoDB table                         |

---

## Additional Notes

- The backend must be provisioned using a local backend before switching to the remote configuration.
