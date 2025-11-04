variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.10.0.0/26"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_key_name" {
  description = "SSH key name for EC2"
  type        = string
  default     = "project2-key"
}

variable "app_bucket_name" {
  description = "S3 bucket for remote state"
  type        = string
  default     = "solar-system-app-bucket-hossam-98787676"
}

