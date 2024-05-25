terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "terraform-statefile-backup-2401"
    key = "key/to/terraform.tfstate"
  }
}