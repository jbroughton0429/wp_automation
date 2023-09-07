Request:
1. Setup a wordpress container on ECS Cluster
2. WP Container should be able to access an RDS instance
3. Container should:
   a. Be built as a DockerImage
   b. Packaged with Packer
   c. Deployed automagically with TF / ECR



### Packer

1. Clean up Variables file 
    - Static builds of repo/server should pull from ./wp_automation/terraform/ecr & rds respectivly 
    - TF outputs the necessary information to file - import said file as variables
    - https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-variables

### Ansible
1. Create a Decent ReadMe

### Terraform
1. Move locals out of networking module
2. Use the vars from main in verbose tags in networking (post-locals replaces)
3. Import ecsTaskExecutionRole and flesh out
4. In ECS.tf - Var out the `image`, gathered from outputs
