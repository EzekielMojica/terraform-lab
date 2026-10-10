terraform {
  # State lives in S3 so every GitHub Actions run sees what earlier runs created.
  backend "s3" {
    bucket       = "terraform-lab-state-ezekiel"
    key          = "terraform-lab/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true # stops two runs from changing state at the same time
  }
}

provider "aws" {
  region = var.region
}
