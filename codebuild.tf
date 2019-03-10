# build image and push to ECR
resource "aws_codebuild_project" "tf-eks-build" {
  name          = "ttf-eks-build"
  description   = "Terraform EKS Build"
  service_role  = "${aws_iam_role.tf-eks-pipeline.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "${var.build_image}"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name"  = "ECR_REPO"
      "value" = "${aws_ecr_repository.tf-eks-ecr.repository_url}"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${var.build_spec}"
  }

}

# staging deploy
resource "aws_codebuild_project" "tf-eks-deploy-staging" {
  name          = "tf-eks-deploy-staging"
  description   = "Terraform EKS Deploy"
  service_role  = "${aws_iam_role.tf-eks-pipeline.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "${var.deploy_image}"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      "name"  = "EKS_NAMESPACE"
      "value" = "tf-eks-staging"
    }
    
    environment_variable {
      "name"  = "ECR_REPO"
      "value" = "${aws_ecr_repository.tf-eks-ecr.repository_url}"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${var.deploy_spec}"
  }

}

# production deploy
resource "aws_codebuild_project" "tf-eks-deploy-prod" {
  name          = "tf-eks-deploy-prod"
  description   = "Terraform EKS Deploy"
  service_role  = "${aws_iam_role.tf-eks-pipeline.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "${var.deploy_image}"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      "name"  = "EKS_NAMESPACE"
      "value" = "tf-eks-prod"
    }
    environment_variable {
      "name"  = "ECR_REPO"
      "value" = "${aws_ecr_repository.tf-eks-ecr.repository_url}"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "${var.deploy_spec}"
  }

}