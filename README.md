# Vprofile Infra

This repository contains the Terraform infrastructure code for deploying an Amazon EKS cluster and its supporting networking resources for the Vprofile GitOps project.

## Overview

The infrastructure provisions:

- AWS VPC with public subnets
- Internet Gateway and public route table
- EKS control plane
- EKS managed node group
- IAM roles for cluster and worker nodes
- OIDC provider for IRSA
- EBS CSI Driver addon
- Argo CD ingress manifest for ALB exposure

## Project Structure

- `main.tf` — main Terraform resources for the AWS VPC, IAM, EKS cluster, node groups, and CSI addon
- `variables.tf` — configurable inputs for region, cluster name, VPC CIDR, subnets, instance type, and node sizing
- `outputs.tf` — exported values such as cluster name, ARN, and endpoint
- `backend.tf` — remote S3 backend configuration for Terraform state
- `argocd-ingress.yaml` — Kubernetes Ingress resource for Argo CD through an AWS ALB
- `iam_policy.json` — IAM policy for the AWS Load Balancer Controller / ALB integration

## Prerequisites

Before running Terraform, ensure you have:

- Terraform installed (v1.x or newer recommended)
- AWS CLI configured with valid credentials
- Permission to create VPC, IAM roles, EKS, and load balancer resources in AWS
- An existing S3 bucket for Terraform remote state if the backend is used as configured

## Configuration

The default values are defined in `variables.tf`:

- Region: `us-east-1`
- Cluster name: `vprofile-eks-cluster`
- VPC CIDR: `10.0.0.0/16`
- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`
- Availability zones: `us-east-1a`, `us-east-1b`
- Node instance type: `m7i-flex.large`

You can override these values using a `terraform.tfvars` file or by passing variables on the command line.

Example:

```hcl
region        = "us-east-1"
cluster_name  = "vprofile-eks-cluster"
instance_type = "t3.medium"
min_size      = 1
max_size      = 2
desired_size  = 1
```

## Deployment Steps

1. Initialize Terraform:

```bash
terraform init
```

2. Review the plan:

```bash
terraform plan
```

3. Apply the infrastructure:

```bash
terraform apply
```

4. Configure kubectl access to the cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name vprofile-eks-cluster
```

## Terraform State

The project is configured to use a remote S3 backend in `backend.tf`:

- Bucket: `gitops-terrafomcode222`
- Key: `eks/terraform.tfstate`
- Region: `us-east-1`

Make sure this bucket exists and is accessible before running `terraform init`.

## Outputs

After deployment, Terraform exports:

- `cluster_name`
- `cluster_arn`
- `cluster_endpoint`

## Argo CD Ingress

The `argocd-ingress.yaml` file configures an ALB Ingress for Argo CD in the `argocd` namespace. It uses:

- `alb.ingress.kubernetes.io/scheme: internet-facing`
- TLS termination with ACM certificate
- HTTPS redirect from port 80 to 443

Adjust the hostname and certificate ARN to match your environment.

## Notes

- This setup is optimized for AWS EKS with public subnets.
- The EBS CSI Driver is enabled via IRSA to support persistent volume workloads.
- The IAM policy file is intended for services that need AWS Load Balancer Controller permissions, especially when integrating ALB with Kubernetes.

## Useful Commands

```bash
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

## License

This project is intended for educational and infrastructure deployment use within the Vprofile GitOps workflow.
