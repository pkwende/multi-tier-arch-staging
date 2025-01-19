terraform {
  backend "s3" {
    bucket         = "pkwende-wk6" # your bucket name
    key            = "demo/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "remote-state-lock" # your dynamoDB table name
  }
}