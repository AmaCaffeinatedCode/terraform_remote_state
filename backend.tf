terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-central-bucket"
    key            = "terraform_remote_state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state-lock-table"
    encrypt        = true
  }
}
