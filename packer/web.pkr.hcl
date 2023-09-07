packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image = var.image
  commit = true
  changes = [
  "ENV TZ Europe/Moscow",
  "ENV DEBIAN_FRONTEND=noninteractive",
  "VOLUME /var/www/html",
  "CMD [\"/usr/sbin/apachectl\", \"-D\", \"FOREGROUND\"]"
  ]
}

build {
  name    = "learn-packer"
  sources = ["source.docker.ubuntu"]

    provisioner "shell" {
      environment_vars = [
      "TZ=Europe/Moscow",
      "DEBIAN_FRONTEND=noninteractive" ]
   
       inline = [
        "/usr/bin/apt-get update",
        "/usr/bin/apt-get -y install ansible"
] 
    }

    provisioner "file" {
      source = "/home/ubuntu/test/vault-password"
      destination = "/tmp/vault-password"
  }


    provisioner "ansible-local" {
      group_vars    = "/home/ubuntu/wp_automation/ansible/vars/"
      playbook_dir  = "/home/ubuntu/wp_automation/ansible"
      playbook_file = "/home/ubuntu/wp_automation/ansible/playbook.yml"
      staging_directory = "/tmp/ansible"
      extra_arguments = ["--vault-password-file=/tmp/vault-password"]
    }

#  post-processors {
 
#    post-processor "docker-tag" {
#      repository = var.repo
#      repository = "913293700147.dkr.ecr.eu-central-1.amazonaws.com/wordpress"
#      tags       = ["latest"]
#    }
#
#    post-processor "docker-push" {
#      ecr_login = true
#      aws_profile = "default"
#      login_server = var.login_server      
#login_server = "https://913293700147.dkr.ecr.eu-central-1.amazonaws.com/wordpress"
#  }
# }
}

