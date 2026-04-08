# ============================================================
# PROJECT 2 — Terraform: Provision AWS EC2 + Install k3s
# ============================================================
# Flow:
#   1. Create a Security Group (firewall rules)
#   2. Launch an EC2 instance
#   3. Auto-install Docker + k3s (lightweight Kubernetes)
#      via user_data — runs once on first boot
# ============================================================

# ── Tell Terraform which cloud provider to use ──────────────
provider "aws" {
  region = var.aws_region
}

# ── Security Group ──────────────────────────────────────────
# A Security Group is AWS's firewall.
# We open exactly the ports our setup needs:
#   22    → SSH  (GitHub Actions uses this to fetch kubeconfig)
#   80    → HTTP
#   6443  → k3s API server (kubectl talks to this remotely)
#   30080 → NodePort where Kubernetes exposes our app
resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Security group for DevOps Project 2"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k3s API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALL outbound traffic (EC2 needs this to pull Docker images, run updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-project-sg"
    Project = "DevOps-Project"
  }
}

# ── EC2 Instance ─────────────────────────────────────────────
# This is our server. Everything runs on it:
#   Docker  → to pull your app image from DockerHub
#   k3s     → single-node Kubernetes (runs your pods)
resource "aws_instance" "devops_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # user_data is a shell script AWS runs ONCE when the instance first boots.
  # Think of it as the "setup script" for your server.
  user_data = <<-EOF
    #!/bin/bash
    set -e   # Stop script if any command fails

    # ---- Update package list ----
    apt-get update -y

    # ---- Install Docker + curl ----
    apt-get install -y docker.io curl
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu   # so ubuntu user can run docker without sudo

    # ---- Install k3s (single-node Kubernetes) ----
    # k3s is a full Kubernetes distribution in one small binary.
    # It's perfect for learning — no complex setup like kubeadm.
    curl -sfL https://get.k3s.io | sh -

    # ---- Make kubeconfig accessible ----
    # kubeconfig is the file kubectl uses to authenticate with k3s.
    # We need the GitHub Actions pipeline to access it via SSH.
    chmod 644 /etc/rancher/k3s/k3s.yaml

    # Copy to ubuntu's home directory
    mkdir -p /home/ubuntu/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config

    # Replace localhost (127.0.0.1) with the server's public IP
    # so kubectl commands from GitHub Actions can reach this server
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    sed -i "s/127.0.0.1/$PUBLIC_IP/g" /home/ubuntu/.kube/config

    chown -R ubuntu:ubuntu /home/ubuntu/.kube
  EOF

  tags = {
    Name    = "devops-project-server"
    Project = "DevOps-Project"
  }
}
