packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

locals {
  filepath = "/home/jayson/test"
}


source "docker" "ubuntu" {
  image   = var.image
  commit  = true
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
      source      = "${local.filepath}/vault-password"
      destination = "/tmp/vault-password"
    }

    provisioner "file" {
      source       = "../terraform/files/database_host"
      destination  = "/tmp/database_host"
    }

    provisioner "ansible-local" {
      group_vars        = "${local.filepath}/wp_automation/ansible/vars"
      playbook_dir      = "${local.filepath}/wp_automation/ansible"
      playbook_file     = "${local.filepath}/wp_automation/ansible/playbook.yml"
      staging_directory = "/tmp/ansible"
      extra_arguments   = ["--vault-password-file=/tmp/vault-password"]
    }

  post-processors {
 
    post-processor "docker-tag" {
      repository = var.repo
      tags       = ["latest"]
    }

    post-processor "docker-push" {
      ecr_login = true
      aws_profile = "default"
      login_server = var.login_server      
  }
 }
}

