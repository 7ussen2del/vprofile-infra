terraform {
  backend "s3" {
    bucket = "gitops-terrafomcode222"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}