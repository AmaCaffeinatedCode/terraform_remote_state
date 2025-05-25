# Terraform Remote State Management

## Project Description

This project establishes a centralized and robust Terraform remote state management solution using AWS services. It provisions an Amazon S3 bucket to securely store Terraform state files and an Amazon DynamoDB table to enable state locking, preventing concurrent modifications and ensuring consistency. The project also includes a CI/CD pipeline configured to automate Terraform workflows, with support for skipping pipeline runs via commit flags.

## Architecture

- **S3 Bucket:** Central repository for all Terraform state files, organized by project and environment via key paths.  
- **DynamoDB Table:** Implements state locking to avoid race conditions during Terraform operations.  
- **Initial Bootstrap:** Uses the local backend to provision S3 and DynamoDB resources.  
- **Remote Backend Migration:** After creation, the project switches to the remote S3 backend for its own state management.  
- **CI/CD Pipeline:** Automates Terraform plan and apply operations with conditional execution based on commit messages.

## Resources Created

| Resource                             | Purpose                                         |
|--------------------------------------|-------------------------------------------------|
| `aws_s3_bucket.terraform_state`      | Stores all Terraform state files securely.      |
| `aws_dynamodb_table.terraform_locks` | Provides locking mechanism for Terraform state. |

## Workflow

1. **Bootstrap Phase:**  
   - Execute Terraform with a local backend to provision the S3 bucket and DynamoDB table.

2. **Backend Reconfiguration:**  
   - Update the project to use the S3 backend for its own Terraform state.

3. **Consuming Projects:**  
   - Configure other Terraform projects to use this centralized backend with isolated key prefixes, ensuring separate state files per project and environment.

4. **CI/CD Automation:**  
   - Terraform plans and applies are automated through GitHub Actions workflows, with an option to skip pipeline runs by including a specific flag in commit messages.

## Usage Instructions

1. Clone and initialize the project:

``` bash
terraform init
terraform apply
```

2. Update the backend configuration (`backend.tf`) to use the new S3 backend:

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

3. Configure all other Terraform projects to use the centralized backend with their own distinct key paths:

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

## CI/CD Pipeline - Skip Execution with Commit Flag

To optimize workflow runs, this project supports skipping the CI/CD pipeline by including the flag `[skip-ci]` anywhere in your commit message. When this flag is detected, the Terraform workflow will not execute, saving resources and time during non-infrastructure-related commits.

Example:

``` bash
git commit -m "Update documentation [skip-ci]"
git push origin main
```

## Variables

| Variable Name         | Description                                  | Example                                 |
|-----------------------|----------------------------------------------|-----------------------------------------|
| `aws_region`          | AWS Region where resources are deployed      | `us-east-1`                             |
| `s3_bucket_name`      | Name of the S3 bucket for storing states     | `terraform-remote-state-central-bucket` |
| `dynamodb_table_name` | Name of the DynamoDB table used for locking  | `terraform-remote-state-lock-table`     |

## Cost and Performance Considerations

- The DynamoDB table is provisioned with minimal read/write capacity units (1 each) to optimize cost while ensuring reliable state locking.
- Server-side encryption and versioning are enabled on the S3 bucket to protect state data and maintain historical versions.

## Additional Notes

- AWS credentials must be managed securely using environment variables, AWS config files, or secrets management in CI/CD pipelines.
- The architecture ensures scalability, maintainability, and security for managing Terraform state across multiple projects and environments.
