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
