terraform {
  backend "s3" {
    # MUST update these values before running terraform init
    bucket         = "background-remover-python-app-s3-bucket"   # <-- update me
    key            = "envs/dev/terraform.tfstate"  # <-- update per environment/path
    region         = "ap-south-1"                  # <-- update to bucket region
    encrypt        = false
    use_lockfile   = true
  }
}
