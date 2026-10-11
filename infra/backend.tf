terraform {
  backend "s3" {
    bucket         = "iac-pipeline-tfstate-662252246018"
    key            = "ecs-platform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "iac-pipeline-tf-lock"
    encrypt        = true
  }
}
