# CodeCommit repo
resource "aws_codecommit_repository" "tf-eks-git" {
  repository_name = "${var.repo_name}"
  description     = "Terraform EKS repository"
  default_branch  = "${var.default_branch}"
}

# ECR repo
resource "aws_ecr_repository" "tf-eks-ecr" {
  name = "${var.repo_name}"
}

# random string for bucket name
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

# pipeline artifact bucket
resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.repo_name}-${random_string.suffix.result}"
  acl           = "private"
  force_destroy = "true"
}

# encryption key for build artifacts
resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}
