provider aws {
  region = "us-east-1" # change to your region
}

module "wireguard" {
  source                        = "vainkop/wireguard/aws"
  version                       = "1.0.1"
  ssh_key_id                    = "ssh-key-0987654"
  vpc_id                        = "vpc-01234567"
  additional_security_group_ids = [aws_security_group.wireguard_ssh_check.id] # for ssh health checks, see below
  subnet_ids                    = ["subnet-76543210"]                         # You'll want a NAT gateway on this, but we don't document that.
  target_group_arns             = [aws_lb_target_group.wireguard.arn]
  asg_min_size                  = 1                                           # a sensible minimum, which is also the default
  asg_desired_capacity          = 2                                           # we want two servers running most of the time
  asg_max_size                  = 5                                           # this cleanly permits us to allow rolling updates, growing and shrinking
  wg_server_net                 = "10.8.0.1/24"                               # client IPs MUST exist in this net
  wg_clients = [
    {
      name = "client1"
      public_key = "QHdbO9TThkXfCJLZWLaSCMFcIylqiyJdm02CYHLWFmI="
      client_ip = "10.8.0.2/32"
    },
    {
      name = "client1"
      public_key = "4BGwG/o0qCiPUstTsDY5ikVzkGZyfEeEuPY6380u0Eg="
      client_ip = "10.8.0.3/32"
    },
    {
      name = "client3"
      public_key = "UKltTV3qmsrmp7DssvP+qAd2m1nBpVXRrsL3AxqsJ2Q="
      client_ip = "10.8.0.4/32"
    },
  ]
}

resource "aws_lb" "wireguard" {
  name               = "wireguard"
  load_balancer_type = "network"
  internal           = false
  subnets            = ["subnet-876543210"] # typically a public subnet
}

resource "aws_security_group" "wireguard_ssh_check" {
  name   = "wireguard_ssh_check"
  vpc_id = "vpc-01234567"

  # SSH access from the CIDR, which allows our healthcheck to complete
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # range that covers public subnet_ids, aws_lb will check the hosts from these ranges
  }
}

resource "aws_lb_target_group" "wireguard" {
  name_prefix = "wg"
  port        = 51820
  protocol    = "UDP"
  vpc_id      = "vpc-01234567"

  health_check {
    port     = 22 # make sure to add additional_security_group_ids with a rule to allow ssh from the loadbalancer range so this test passes.
    protocol = "TCP"
  }

}

resource "aws_lb_listener" "wireguard" {
  load_balancer_arn = aws_lb.wireguard.arn
  port              = 51820
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wireguard.arn
  }
}
