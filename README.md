# Automated Wordpress Install

- [Automated Wordpress Install](#automated-wordpress-install)
- * [Introduction](#introduction)
- [Prerequisites](#prerequisites)
  * [Getting Started](#getting-started)
- [Variables](#variables)
    + [Terraform](#terraform)
    + [Ansible](#ansible)
    + [Packer](#packer)
- [Installation](#installation)
  * [Validating Installation](#validating-installation)
    
- [Approach and Execution](#approach-and-execution)
  * [Deploy and Interaction](#deploy-and-interaction)
  * [Problems ](#problems)
  * [HA/Automated](#haautomated)
  * [Improvements](#improvements)

## Introduction

This is an automated WordPress install using the following resources

* Terraform
* Ansible
* Packer

We utilize the following AWS Services:

* ECS
* RDS
* ECR

Upon full execution, you will have an automated WordPress Instance with Elastic Container Services

# Prerequisites

Your development environment should contain the necessary packages to deploy these services. Provided with-in this repo is `dev-setup.sh` in order to get you started.

Upon successful setup of your dev environment, please be sure to run: **aws configure**. 

## Getting Started

# Variables

### Terraform

Terraform will require you to populate a `terraform.tfvars` file with the following:

* project
* environment
* region
* availability_zones (list)
* vpc_cidr
* public_subnets_cidr (list)
* private_subnets_cidr (list)
* app_count

An example of this is:

```
// terraform.tfvars //
project               = "wordpress"
environment           = "development"
region                = "eu-central-1"
availability_zones    = ["eu-central-1a", "eu-central-1b"]
vpc_cidr              = "10.0.0.0/16"
public_subnets_cidr   = ["10.0.10.0/24", "10.0.20.0/24"] //List of Public subnet cidr range
private_subnets_cidr  = ["10.0.30.0/24", "10.0.40.0/24"] //List of private subnet cidr range
app_count             = "1"
db_user               = "username"
```
***Note on `db_user`***: This must match the database user set in your ansible-vault.

### Ansible
Variables are located: `./wp_automation/ansible/vars`

By default, these plain-text variables should not need any changes

`Ansible-Vault` is utilized to secure passwords. The Password for this is in the password vault under `WordPress Ansible Vault'

It is recommended to change these passwords upon the first run:

```
ansible-vault edit vault.yml
```

A plaintext of this password should be loaded outside of the Git Repo so that Packer can auto-run. The current path for this is:
`~/vault-password`


### Packer

Until this can be properly automated, you will need to pass the 'repo' and 'login_server' ARN's to `variables.pkr.hcl`

1. Run the following, replacing the `APP` Variable with your filepath:
```
APP=~/wp_automation/

cd $APP/terraform
terraform apply -target=aws_ecr_repository.wordpress -auto-approve
terraform apply -target=local_file.ecr.arn -auto-approve
terraform apply -target=local_file.ecr_url -auto-approve
```

2. Navigate to the Packer directory and replace the `repo` and `login_server` string from: `/terraform/files/ecr_arn & ecr_url`
3. Replace the local filepath variable found in `web.pkr.hcl` 
   * `locals { filepath = "path-to-git-repo" }`

In this scenario, the `vault-password` is located in a directory above your git repo (**read**: Your home directory). If you plan on storing your `vault-password` outside of the home directory, make the appropriate changes to the file provisioner.

## Installation

After making the necessary changes to your variable (see above), the steps to install is as follows:

1. Create the ECR repo
```
CD <path-to-repo>/wp_automation
terraform apply -target=aws_ecr_repository.wordpress -auto-approve
terraform apply -target=local_file.ecr.arn -auto-approve
terraform apply -target=local_file.ecr_url -auto-approve
```
This will create the ECR necessary for your DockerImage, while also adding the necessary files for you to pull the ARN/URL 

2. Update your `variables.pkr.hcl`
Update your packer variables file to add `repo` and `login_server`.  This information can be found in *~/wp_automation/terraform/files*

3. Run Packer Build
```
cd ~/wp_automation/packer/
packer build .
```
3. Upon completion, run your Terraform code
```
cd ~/wp_automation/terraform
terraform validate
terraform plan
terraform apply
```
## Validating Installation

When you have completed the run of `Terraform`, you should be able to navigate to the ECS Console and Identify the Hostname for your wordpress installation


## Approach and Execution
The initial task for this challenge was as follows:
Use Tools such as Terraform, Packer, and Ansible
Setup a WordPress container on an ECS Cluster

I approached this scenario by identifying the initial challenge: Automate the build of an ECS Cluster.

Breaking this down into bite-size chunks:
Automate the build-out of the AWS Infrastructure
VPC & Networking
ECR
RDS
ECS
Build a Docker Compose setup of WP and MariaDB via Ansible to see how they interact locally
Use Packer to auto-build and deploy the image locally, and then ECR
Clean up secrets, and variables and flesh out the project

### Deploy & Interaction
The way this is deployed is as follows:
ECR is deployed via Terraform's ``target`` flag
Execution of packer does the following: 
Build out Ansible image of WordPress
Push to ECR
Execution of `terraform apply` will run the following:
Build the Network out
Setup RDS with the supplied information
Deploy an ECS Cluster with Service/Task of WordPress

The ECS Cluster communicates to the RDS Instance in AWS. Building out of the image:latest triggers the Task to update

### Problems 
I created a `TODO.md` file that outlines the current issues, and how to tackle them.  I would say the main issue I had was refreshing my memory on Ansible/Packer as it had been several years since I've worked with this software.  
My first attempt was to use an existing AMI via Packer and build with Ansible and Push. I ran into issues here as the AMI was not a 'docker build' and ECR refused to push this 
Remediated by building through docker on the local machine and pushing
I ran into issues with Ansible deployment strategies and ended up locating a playbook that needed some heavy modification instead of re-creating the wheel. This cut down deployment time dramatically
I have no experience with ECS. Before ECS, we would deploy our Docker Images, set up Load Balancing, and the pre-ecs days of clustering the containers. 
My approach to this was to take the generated image in ECR and create an ECS Cluster/Service/Task Definition manually. Once I could connect to the Database, I used `terraform import` to review and build out my `ecs.tf`.

One of the items that still needs to be completed is to create the IAM Role that I manually deployed. This is in my TODO as I ran out of time to complete this.

### HA/Automated
This is somewhat designed to be automated for deployment. A `bash` script is identified in this README on how to automate the deployment. One of the issues still to be tackled is a few hardcoded variables. Once this is identified and remediated, a deployment via either TF Cloud or CI/CD with a Terraform plugin should be able to deploy this as necessary

For High Availability, as you may have discovered, I did not HA the RDS Database, or set up Load Balancers in the Cluster as this was a quick deployment.  In the future, I would:
Build our RDS Instance as multi-az as a first step. Also, set backups and test backup solutions through RDS.  We could get super complicated with Database HA, standby instances, etc
I would Have more than 1 task running at the same time for ECS, setup spread placement via 3 az's, and EC2 Auto Scaling to begin with

### Improvements
If this was a large deployment, I would look into EKS for Kubernetes deployments.  Setting up Helm Charts, using Waypoint for management, and being able to utilize the TF Cloud infrastructure for deployment strategies involving more than 1 party would make things run a little smoother. Ansible Deployments, Packer building, etc. introduces many 3rd party building/deployment products that have the potential to break on upgrades.  
