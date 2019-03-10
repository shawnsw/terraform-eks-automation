# Terraform EKS automation

This is an example of using Terraform to automate EKS cluster creation and application deployment with CodeBuild and CodePipeline.

## Components

### VPC

`vpc.tf` configures the VPC module to creates a VPC with public and private subnets across all AZs and a NAT gateway for internet access.

### EKS cluster

`eks.tf` configures the EKS module to create an EKS cluster with two node groups, on demand and spot fleet, across all AZs.

`eks_vars.tf` defines all the variables needed.

### CI/CD pipeline

`codebuild.tf` creates 3 Codebuild projects: Build, StagingDeploy and ProdDeploy

`codepipeline.tf` creates an CI/CD 3 stage pipeline with the 3 Codebuild projects, plus a manual step for promoting staging to prod.

`repos.tf` creates CodeCommit git reposity, ECR container registry repo and pipeline artifact bucket

`iam.tf` defines the IAM role and policy used by CodeBuild and CodePipeline

### Main

`main.tf` defines Terraform version and providers

`vars.tf` defines variables

### Go Application

The sample Go application repo contains a simple Go hello world app, build specs and Kubernetes deployment specs.

Repo link: [https://github.com/shawnxlw/go-k8s-cicd/]

## How to use

### Install dependancies

If you are a cool kid who brews, run the following oneliner:

```
brew install terraform awscli aws-iam-authenticator kubectl
```

Alternatively, use the IDE [https://github.com/shawnxlw/infra-dev-env/] container

```
docker run -v ~/:/root /project/path:/workspace -ti shawnxlw/ide /bin/bash
```

### Configure AWS

Admin access recommanded.

```
aws configure
```

### Configure varibles

You can redefine the variables in `vars.tf` and `eks_vars.tf`, but you should be able to run this as is without the need to change anything.

### Terraform apply

When you are ready do a terraform run:

```
terraform init
terraform plan
terraform apply
```

The entire terraform apply takes about 10 minutes to finish.

### Test cluster

Once the apply finishes, you should see two files pop up in your working directory:

`config-map-aws-auth_terraform-eks-dev.yaml` This configmap defines AWS role mapping, you don't need to touch it unless you need to add new IAM roles and users.

`kubeconfig_terraform-eks-dev` This is the kube config file, you can copy this file to `~/.kube/config` for easy cluster access. Alternatively, you can specify kube config in your kubectl commands, for example:
```
kubectl get node --kubeconfig kubeconfig_terraform-eks-dev
```

### Commit to the git repo

After the CodeCommit repo is ready, you will need to go to `IAM -> Users -> Security Credentials -> SSH keys for AWS CodeCommit
 | HTTPS Git credentials for AWS CodeCommit` and either add your SSH public key in, or create a username and password.

 Next step, clone the repo, and then commit the Go Application code to the repo, this will trigger the CodePipeline.

 ### Pipeline

 Upon your commit, the pipeline will start building, and then deploying to staging automatically, it will then stop for manual confirmation before the prod deployment.

 When deployed, check the pod and service status with

 ```
 k get pod -n tf-eks-staging --kubeconfig kubeconfig_terraform-eks-dev
 k get svc -n tf-eks-staging --kubeconfig kubeconfig_terraform-eks-dev
 ```

 Please note that the ELB takes a few minutes to be ready. To veryfiy the app works, try:

 ```
 curl $(kubectl get svc -n tf-eks-staging --kubeconfig kubeconfig_terraform-eks-dev | tail -1 | awk '{print $4}')
```

You should see something like this:

```
Hey!, you've requested: /
```

Now in CodePipeline, approve the `PromoteToProd` step, and you should see the app being deployed to `tf-eks-prod` namespace (should be in a separate prod cluster in real world usecase)

 ```
 k get pod -n tf-eks-prod --kubeconfig kubeconfig_terraform-eks-dev
 k get svc -n tf-eks-prod --kubeconfig kubeconfig_terraform-eks-dev
 ```

Next change `Hey` in the `main.go` to `Hello`, commit the code, wait a couple of minutes then do another curl, and you should see new message:

```
Hello!, you've requested: /
```
