Request:
1. Setup a wordpress container on ECS Cluster
2. WP Container should be able to access an RDS instance
3. Container should:
   a. Be built as a DockerImage
   b. Packaged with Packer
   c. Deployed automagically with TF / ECR



1. TF Automate: ECS
2. Packer Deploy to ECR
3. Setup ECS
4. Var out all of the files
5. Setup Networking with Terraform
6. Security of ECR
5. Automate with start/destroy



Done:
* Automate ECR
* Automate RDS
* Build Docker Image of WP
* Build WP with Ansible
* Packer Image Build



### Packer

1. Clean up Variables file 
    - Static builds of repo/server should pull from ./wp_automation/terraform/ecr & rds respectivly 
    - TF outputs the necessary information to file - import said file as variables
    - https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-variables

### Ansible
1. Create a Decent ReadMe
2. Drop passwords into ansible vault
3. Use 'lookup' to query terraform output on specific variables needed for ansible
  - Info here:
    * https://stackoverflow.com/questions/24003880/ansible-set-variable-to-file-content
    * https://docs.ansible.com/ansible/latest/collections/community/hashi_vault/docsite/lookup_guide.html


### Terraform
1. Move locals out of networking module
2. Use the vars from main in verbose tags in networking (post-locals replaces)

