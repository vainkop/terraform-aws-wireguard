terraform {
  backend "s3" {}
}

provider "aws" {
  version = "= 3.32.0"
  region  = var.region
}

data "aws_eip" "wireguard" {
  tags = {
    Name = "wireguard"
  }
}

data "template_file" "wg_client_data_json" {
  template = file("${path.module}/templates/client-data.tpl")
  count    = length(var.wg_clients)

  vars = {
    friendly_name        = var.wg_clients[count.index].friendly_name
    client_pub_key       = var.wg_clients[count.index].public_key
    client_ip            = var.wg_clients[count.index].client_ip
    persistent_keepalive = var.wg_persistent_keepalive
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "wireguard_launch_config" {
  name_prefix          = "wireguard-${var.env}-${var.region}-"
  image_id             = var.ami_id == null ? data.aws_ami.ubuntu.id : var.ami_id
  instance_type        = var.instance_type
  key_name             = var.ssh_key_id
  iam_instance_profile = (var.use_eip ? aws_iam_instance_profile.wireguard_profile[0].name : null)
  user_data = templatefile("${path.module}/templates/user-data.txt", {
    wg_server_private_key = var.wg_server_private_key,
    wg_server_net         = var.wg_server_net,
    wg_server_port        = var.wg_server_port,
    peers                 = join("\n", data.template_file.wg_client_data_json.*.rendered),
    use_eip               = var.use_eip ? "enabled" : "disabled",
    eip_id                = data.aws_eip.wireguard.id,
    wg_server_interface   = var.wg_server_interface
  })
  security_groups             = [aws_security_group.sg_wireguard.id]
  associate_public_ip_address = var.use_eip

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wireguard_asg" {
  name                 = aws_launch_configuration.wireguard_launch_config.name
  launch_configuration = aws_launch_configuration.wireguard_launch_config.name
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  vpc_zone_identifier  = var.subnet_ids
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = aws_launch_configuration.wireguard_launch_config.name
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "wireguard"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "tf-managed"
      value               = "True"
      propagate_at_launch = true
    },
  ]
}
