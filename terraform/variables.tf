# ============================================================
# variables.tf — All configurable inputs in one place
# ============================================================
# You only need to change values here — main.tf stays untouched.
# ============================================================

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID (region-specific!)"
  type        = string
  # ⚠️  This AMI is for us-east-1 only.
  # Find your region's AMI at: https://cloud-images.ubuntu.com/locator/ec2/
  # Filter by: 22.04, amd64, hvm:ebs-ssd
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "EC2 instance size (t3.micro = free tier)"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Name of your AWS Key Pair (for SSH access)"
  type        = string
  # ⚠️  Steps to get this:
  #   1. AWS Console → EC2 → Key Pairs → Create key pair
  #   2. Name it (e.g. "devops-project2-key")
  #   3. Download the .pem file
  #   4. Put the NAME (not the file path) here
  #   5. Add the .pem file content as a GitHub Secret called EC2_SSH_KEY
  default     = "devops-project2-key"
}
