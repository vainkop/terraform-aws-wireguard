variable "region" {
  type = string
}

variable "ssh_key_id" {
  description = "A SSH public key ID to add to the VPN instance."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
}

variable "asg_min_size" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "asg_desired_capacity" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "asg_max_size" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "vpc_id" {
  description = "The VPC ID in which Terraform will launch the resources."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list."
}

variable "wg_clients" {
  type        = list(object({ friendly_name = string, public_key = string, client_ip = string }))
  description = "List of client objects with IP and public key. See Usage in README for details."
}

variable "wg_server_net" {
  default     = "10.8.0.1/24"
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
}

variable "wg_server_port" {
  default     = 51820
  description = "Port for the vpn server."
}

variable "wg_persistent_keepalive" {
  default     = 25
  description = "Persistent Keepalive - useful for helping connection stability over NATs."
}

variable "use_eip" {
  type        = bool
  default     = false
  description = "Create and use an Elastic IP in user-data on wg server startup."
}

variable "use_ssm" {
  type        = bool
  default     = false
  description = "Whether to use SSM to store Wireguard Server private key."
}

variable "target_group_arns" {
  type        = list(string)
  default     = null
  description = "Running a scaling group behind an LB requires this variable, default null means it won't be included if not set."
}

variable "env" {
  default     = "prod"
  description = "The name of environment for WireGuard. Used to differentiate multiple deployments."
}

variable "wg_server_private_key" {
  type        = string
  default     = null
  description = "WG server private key."
}

variable "ami_id" {
  default     = null # we check for this and use a data provider since we can't use it here
  description = "The AWS AMI to use for the WG server, defaults to the latest Ubuntu 20.04 AMI if not specified."
}

variable "wg_server_interface" {
  default     = "eth0"
  description = "The default interface to forward network traffic to."
}

variable "prometheus_server_ip" {
  type        = string
  default     = null
  description = "Prometheus server IP."
}

variable "use_route53" {
  type        = bool
  default     = false
  description = "Whether to use SSM to store Wireguard Server private key."
}

variable "route53_hosted_zone_id" {
  type        = string
  default     = null
  description = "Route53 Hosted zone ID."
}

variable "route53_record_name" {
  type        = string
  default     = null
  description = "Route53 Record name."
}

variable "route53_geo" {
  type        = any
  default     = null
  description = "Route53 Geolocation config."
}
