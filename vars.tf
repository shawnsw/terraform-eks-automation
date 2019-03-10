# define aws region
variable "region" {
  default = "ap-southeast-2"
}

# CodeCommit and ECR repo name, also as artifact bucket prefix
variable "repo_name" {
  default = "tf-eks"
}

# define default git branch
variable "default_branch" {
  default = "master"
}

# define docker image for build stage
variable "build_image" {
  default = "aws/codebuild/docker:18.09.0"
}

# define build spec for build stage
variable "build_spec" {
  default = "buildspec/build.yml"
}

# define docker image for deploy stage
variable "deploy_image" {
  default = "shawnxlw/ide"
}

# define build spec for deploy stage
variable "deploy_spec" {
  default = "buildspec/deploy.yml"
}
